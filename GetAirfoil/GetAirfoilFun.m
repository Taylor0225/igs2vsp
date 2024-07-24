function GetAirfoilFun(upfileName,downfileName,unit)
%% 本函数用于读取上下表面的翼型数据文件并生成翼型数据标准dat文件

arguments
upfileName string
downfileName string
unit string {mustBeMember(unit,["m","mm","cm"])}
end




upfilename="./output/"+upfileName+".dat";
downfilename="./output/"+downfileName+".dat";

switch  unit
    case "m"
        unit_temp=1;


    case "mm"
        unit_temp=1/1000;


    case "cm"
        unit_temp=1/100;
end

%% 读取上表面数据
id=fopen(upfilename,'rt');
upDataGroup=[];
if id == -1
error("缺少上表面数据")
end

while ~feof(id)
    line=fgetl(id); % 读取一行
    point=str2num(line); % 转数字
    if numel(point)==1
        upDataGroup(end+1).data=[];
    elseif numel(point)==3
        upDataGroup(end).data(end+1,:)=point*unit_temp;
    else
        disp('error')
    end
end

for i=1:numel(upDataGroup)
    y(i)=abs(upDataGroup(i).data(1,2));
end

[~,index]=sort(y,'ascend'); % 递增排序
oldgroup=upDataGroup;

for i=1:numel(index)
    upDataGroup(i)=oldgroup(index(i));
end
clear oldgroup
fclose(id);

%% 读取下表面数据
id=fopen(downfilename,'rt');
downDataGroup=[];
if id == -1
error("缺少下表面数据")
end

while ~feof(id)
    line=fgetl(id); % 读取一行
    point=str2num(line); % 转数字
    if numel(point)==1
        downDataGroup(end+1).data=[];
    elseif numel(point)==3
        downDataGroup(end).data(end+1,:)=point*unit_temp;
    else
        disp('error')
    end
end

for i=1:numel(downDataGroup)
    y(i)=abs(downDataGroup(i).data(1,2));
end

[~,index]=sort(y,'ascend'); % 递增排序
oldgroup=downDataGroup;

for i=1:numel(index)
    downDataGroup(i)=oldgroup(index(i));
end

clear oldgroup
fclose(id);

%% 构建翼型类
for i=1:numel(upDataGroup)
    % 名字内部i-1是方便vsp建模
    airfoil(i)=AirFoil(strcat('airfoil_',num2str(i-1)),upDataGroup(i).data,downDataGroup(i).data);
    airfoil(i).OutputAirfoilDatFile() % 输出翼型文件
    %airfoil(i).Plot
end

for i=1:numel(airfoil)
    angle(i)=airfoil(i).RoateAngle;
end

for i=1:numel(airfoil)
    Dx_c(i)=airfoil(i).LeadEdgeLocation(1)/airfoil(i).Chord;
end

for i=1:numel(airfoil)
    Dy_c(i)=airfoil(i).LeadEdgeLocation(3)/airfoil(i).Chord;
end

for i=1:numel(airfoil)
    y(i)=abs(airfoil(i).SpanWiseLocation);
end

for i=1:numel(airfoil)
    c(i)=airfoil(i).Chord;
end
dy=diff(y);
%% 输出格式文件

id=fopen("./output/"+"airfoil.txt","w");

fprintf(id,"%8s     %8s     %8s     %8s","SecIndex", "Spanwise" ,"Root","Tip");

for i=1:(numel(upDataGroup)-1)

    fprintf(id,"\n %8d      %8f     %8f     %8f",i,dy(i),c(i),c(i+1));

end



fprintf(id,"\n\n\n%10s     %10s     %10s     %10s","AirfoilId", "dx/c" ,"dy/c","angle");
fprintf(id,"\n 注释：基于OpenVSP格式要求，下边的angle自动取了负号");

for i=1:(numel(upDataGroup))

    fprintf(id,"\n %10d      %10f     %10f     %10f",i-1,Dx_c(i),Dy_c(i),-angle(i));

end


fclose(id);

%% 输出vsp的脚本

id=fopen("./output/"+"wing.vspscript","w");

fprintf(id,"//============= 这是针对飞翼飞机的vsp脚本，请在vsp中运行该脚本=============\n");
fprintf(id,"void main() \n");
fprintf(id,"{ \n");

fprintf(id,"//=添加一个机翼 \n");
fprintf(id,"string wid = AddGeom( ""WING"", """" ); \n");

fprintf(id,"//=针对该机翼插入%d段 \n",numel(upDataGroup)-1);
for i=1:(numel(upDataGroup)-1)
    fprintf(id,"InsertXSec( wid, 1, XS_FOUR_SERIES );  \n");
end
fprintf(id,"//=剪裁初始第一段机翼 \n");
fprintf(id,"CutXSec( wid, 1 ); \n");

for i=1:(numel(upDataGroup)-1) % 分别处理机翼的每一段
    fprintf(id,"//==处理第%d段机翼;  \n",i);
    fprintf(id,"SetParmVal( wid, ""Root_Chord"", ""XSec_%d"", %d );  \n",i,c(i));
    fprintf(id,"SetParmVal( wid, ""Tip_Chord"", ""XSec_%d"", %d );  \n",i,c(i+1));
    fprintf(id,"SetParmVal( wid, ""Span"", ""XSec_%d"", %d );  \n",i,dy(i));
    fprintf(id,"Update(); \n");
end

fprintf(id,"//=处理翼型 \n");
fprintf(id,"string xsec_surf; \n");
fprintf(id,"string xsec; \n");
for i=1:(numel(upDataGroup))
    fprintf(id,"//==处理第%d个翼型;  \n",i-1);
    fprintf(id,"xsec_surf = GetXSecSurf( wid, %d );  \n",i-1);
    fprintf(id,"ChangeXSecShape( xsec_surf, %d, XS_FILE_AIRFOIL);  \n",i-1);
    fprintf(id,"xsec = GetXSec( xsec_surf, %d );  \n",i-1);
    fprintf(id,"ReadFileAirfoil( xsec, ""airfoil_%d.dat"" );  \n",i-1);
    fprintf(id,"Update(); \n");
end

fprintf(id,"//=翼型调整 \n");
for i=1:(numel(upDataGroup))
    fprintf(id,"//==处理第%d个翼型;  \n",i-1);
    fprintf(id,"SetParmVal( wid, ""DeltaX"", ""XSecCurve_%d"", %d );  \n",i-1,Dx_c(i));
    fprintf(id,"SetParmVal( wid, ""DeltaY"", ""XSecCurve_%d"", %d );  \n",i-1,Dy_c(i));
    fprintf(id,"SetParmVal( wid, ""Theta"", ""XSecCurve_%d"", %d );  \n",i-1,-angle(i));
    fprintf(id,"Update(); \n");
end

fprintf(id,"//==== Check For API Errors ====// \n");
fprintf(id,"while ( GetNumTotalErrors() > 0 ) \n");
fprintf(id,"{ \n");
fprintf(id," ErrorObj err = PopLastError(); \n");
fprintf(id,"Print( err.GetErrorString() ); \n");
fprintf(id,"} \n");
fprintf(id,"} \n");

fclose(id);

end
