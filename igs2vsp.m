%% 此脚本基于igesToolbox和自编函数用于处理igs文件得到翼型数据然后导入Openvsp可以绘制机翼用于后续处理
% 转化后的单位为m
clc;clear

%% step 0: 输入文件名称和初始设置

FileName          = "Wing.igs";%"x56_aero.IGS";
saveFileName      = "UpSurf";  % "DownSurf" or  "UpSurf"
R                 = [2000;0;1000]; % 投影的初始原点
normal            = [0;0;-1]; % 投影方向
pdir              = [-1;0;0]; % 切割方向

dp_mat            = [20;20]; % 切割方向网格间距
nppos_mat         = [300;150]; % 切割正方向点数量
cutXposition      = [5000;6000];% x方向切割坐标
cutYposition      = [10;3990]; % y方向切割坐标
unit              = "mm";   % 单位  

% 添加相关函数路径
addpath(genpath(".\igesToolbox\"));
addpath(genpath(".\input"));
addpath(genpath(".\output"));
addpath(genpath(".\GetAirfoil"));


%% step 1: 配置文件igesToolbox环境文件

% 如果已经配置该文件可以注释掉
% makeIGESmex


%% step 2: 导入igs文件
[ParameterData,EntityType,numEntityType,unknownEntityType,numunknownEntityType]=iges2matlab(FileName);

%% step 3：获取投影数据
if saveFileName=="UpSurf" % 根据上下表面调整相关数值
    normal(3) = -1;
    R(3) = abs(R(3));
else
    normal(3) = 1;
    R(3) = -abs(R(3));
end

normal=normal/norm(normal);  %归一化
pdir=pdir-dot(pdir,normal)*normal; % 投影
pdir=pdir/norm(pdir); % 归一化
sdir=cross(pdir,normal); % Second (secondary) direction of grid
sdir=sdir/norm(sdir); % 归一化
npneg=0; % 切割反方向点数量


nspos=0; % Number of positive grids in secondary direction
nsneg=0; % Number of negative grids in secondary direction

% 检查数据维度
if numel(nppos_mat)==numel(cutXposition)&&numel(cutXposition)==numel(cutYposition)...
        &&numel(dp_mat)==numel(nppos_mat)
    fprintf("数组维度匹配\n")
else
    error("数组维度不匹配")
end

Points = cell(numel(cutYposition),1);
srfind_cell = cell(numel(cutYposition),1);

parfor cut_i = 1:numel(cutYposition) % 处理每一个截面
    fprintf("已经计算完第%d个截面\n",cut_i)
    nppos = nppos_mat(cut_i);
    R_real = [cutXposition(cut_i);cutYposition(cut_i);R(3)];

    % 调用投影函数
    [model,~,srfind,~,~,~]=projpartIGES(ParameterData,R_real,normal,pdir,sdir,dp_mat(cut_i),nppos,npneg,nspos,nsneg);

    srfind_cell{cut_i}=srfind;
    Points{cut_i} = model(:,srfind>0);
end

%%
%------绘图igs图像 Plot the IGES object
for cut_i = 1:numel(cutYposition) % 处理每一个截面
    dp = dp_mat(cut_i);
    nppos = nppos_mat(cut_i);
    R_real = [cutXposition(cut_i);cutYposition(cut_i);R(3)];
    srfind = srfind_cell{cut_i};
    %--------------------绘图
    Pnts=zeros(3,(npneg+1+nppos)*(nsneg+1+nspos));

    ind=0;
    for i=-npneg:nppos
        for j=-nsneg:nspos
            ind=ind+1;
            Pnts(:,ind)=R_real+i*dp*pdir+j*dp*sdir;
        end
    end

    hold on
    plot3(Pnts(1,:),Pnts(2,:),Pnts(3,:),'.','Color',[0.1 0.5 0.4]);

    % Plot normal, starting at grid origin
    lines=[R_real R_real+15*dp*normal];
    hold on
    plot3(lines(1,:),lines(2,:),lines(3,:),'r-');

    % Plot pdir, starting at grid origin
    lines=[R_real R_real+15*dp*pdir];
    hold on
    plot3(lines(1,:),lines(2,:),lines(3,:),'g-');

    % Plot sdir, starting at grid origin
    lines=[R_real R_real+15*dp*sdir];
    hold on
    plot3(lines(1,:),lines(2,:),lines(3,:),'b-');

    % Plot projected points
    hold on
    plot3(Points{cut_i}(1,:),Points{cut_i}(2,:),Points{cut_i}(3,:),'.','Color',[0.0 0.8 0.8]);
    %--------------------绘图
end


figno=1;
hold on
plotIGES(ParameterData,1,figno,[],0);
axis equal
xlabel("x")
ylabel("y")
zlabel("z")

%% step 4：导出当前截面的数据
if ~ismember(saveFileName,["UpSurf","DownSurf"])
    error("检查输出文件名字")
end

id=fopen("./output/"+saveFileName+".dat","w");

for i = 1:numel(Points)
    fprintf(id,"%d \n",size(Points{i},2));

    for j = 1:size(Points{i},2)
        fprintf(id,"%8f     %8f     %8f \n",Points{i}(1,j),Points{i}(2,j),Points{i}(3,j));
    end
end

fclose(id);

%% step 5：调用整理翼型数据的函数
clc

GetAirfoilFun("UpSurf","DownSurf",unit)











