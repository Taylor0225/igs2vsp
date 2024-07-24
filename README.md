[TOC]

# igs2vsp
igs2vsp is A matlab script transform .igs file to OpenVSP's .vspscript file.
this script based on matlab allows you quickly generate an openvsp model from existing igs model.

igs2vsp是本人编写的基于matlab的脚本，它可以将igs文件转为OpenVSP支持的脚本文件vspstript，因而可以快速建立OPENVSP内的模型，**目前仅支持转化机翼外形**。本项目结合了开源的igs文件读取项目[igesToolbox](https://www.mathworks.com/matlabcentral/fileexchange/13253-iges-toolbox)，再次向作者表示感谢。

以下将简单介绍该脚本的使用。

## 脚本内文件介绍

该脚本名称为igs2vsp，打开之后有四个文件夹和一个m脚本：

1. 其中GetAirfoil文件夹内为翼型处理函数，用于将切片得到的翼型数据整合成为翼型标准dat文件，同时计算弦长、展长等参数用于后续生成vsp脚本文件；
2. igesToolbox文件夹为开源的igs文件读取项目，详细内容见该文件对应exchange网站；
3. input文件夹用于存储igs源文件，使用者需要将igs文件放置该文件夹内；
4. output文件夹用于存放导出后的文件，包括翼型数据（dat文件）、vsp建模数据（txt文件）、上下表面切片离散点数据（dat文件）、vsp脚本文件（wing.vspstript）。

## 使用流程

1. 机翼igs模型展向需要调整为在y轴，弦向需要在x轴，z平面为机翼的垂向；

2. 将igs文件放入input文件夹内，建议使用英文命名；

3. 打开igs2vsp脚本；

4. 修改初始step 0：

   ```matlab
   FileName          = "Wing.igs";%"x56_aero.IGS";
   saveFileName      = "UpSurf";  % "DownSurf" or  "UpSurf"
   R                 = [2000;0;1000]; % 投影的初始原点
   normal            = [0;0;-1]; % 投影方向
   pdir              = [-1;0;0]; % 切割方向
   
   dp_mat            = [20;20]; % 切割方向网格间距
   nppos_mat         = [300;150]; % 切割正方向点数量
   cutXposition      = [5000;6000];% x方向切割坐标
   cutYposition      = [10;3990]; % y方向切割坐标
   ```

   FileName：igs文件名；

   saveFileName：保存切片离散点名，只能使用 "DownSurf" or  "UpSurf"；

   R：投影的参考源点，一般选择机翼上方一个点就行，注意不要选择机翼内部的点；

   normal：无需修改；

   pdir：无需修改；

   dp_mat：离散点间距，注意单位需要和igs文件内单位一致；

   nppos_mat ：离散点数量，这些点需要覆盖机翼弦向；

   cutXposition：x方向切割坐标

   cutYposition：y方向切割坐标

5. （可选）%% step 1: 配置文件igesToolbox环境文件% 如果已经配置该文件可以注释掉，配置后可能在根目录产生大量文件，将其剪切至igesToolbox文件夹即可；

6. saveFileName分别设置为"DownSurf" or  "UpSurf"，并且操作两次，每次会展示机翼上/下切片离散点的位置，需要根据图像上的情况作相应调整。

7. 新建vsp3文件，点击import，导入output内的wing.vspstript脚本即可；

8. 可根据需要微调相关参数。

## 说明

- 只能用于机翼建模，小翼无法处理；
- vsp处理后外形会有失真，后续计算带来的误差本项目并不负责，再次声明。

## 联系方式

如果有任何问题可以联系邮箱：liyingjian@nuaa.edu.cn



