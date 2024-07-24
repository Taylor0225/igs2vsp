function [x,y] = GetTwoLineCrossPoints(Line1Cell,Line2Cell)
%% 给定两条线求解交点
% Line1Cell 是第1条直线的上两个点坐标 用cell表示
% Line2Cell 是第2条直线的上两个点坐标 用cell表示
% x y是输出点坐标
% 
% 2024年7月13日
arguments
Line1Cell cell
Line2Cell cell
end

if numel(Line1Cell)~=2||numel(Line2Cell)~=2
    error("GetTwoLineCrossPoints：输入元胞数组必须是二维的")
end

if numel(Line1Cell{1})~=2||numel(Line1Cell{2})~=2
 error("GetTwoLineCrossPoints：第1条直线的元胞数组包含的点必须是二维的")
end

if numel(Line2Cell{1})~=2||numel(Line2Cell{2})~=2
 error("GetTwoLineCrossPoints：第2条直线的元胞数组包含的点必须是二维的")
end
%% 旋转平移初始点
T = rand(2,1); % 随机平移
theta = rand(1);
R = [cos(theta),-sin(theta);sin(theta),cos(theta)]; % 随机转动


% 分别针对两条直线上的点进行旋转和平移
for i=1:2
Line1Cell{i} = R*(T+[Line1Cell{i}(1);Line1Cell{i}(2)]);
end
for i=1:2
Line2Cell{i} = R*(T+[Line2Cell{i}(1);Line2Cell{i}(2)]);
end

%% 求解第1条直线的系数A1*x+B1*y=1
Coeff = [Line1Cell{1}(1),Line1Cell{1}(2);Line1Cell{2}(1),Line1Cell{2}(2)]\[1;1];
A1 = Coeff(1);
B1 = Coeff(2);

%% 求解第2条直线的系数A2*x+B2*y=1
Coeff = [Line2Cell{1}(1),Line2Cell{1}(2);Line2Cell{2}(1),Line2Cell{2}(2)]\[1;1];
A2 = Coeff(1);
B2 = Coeff(2);

%% 求交点
Coeff = [A1,B1;A2,B2]\[1;1];
%% 逆处理
Coeff = (R')*Coeff - T;
x = Coeff(1);
y = Coeff(2);
end