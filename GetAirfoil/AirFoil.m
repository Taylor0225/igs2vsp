classdef AirFoil<handle
    
    properties
        name % �ַ���
        LeadEdgeLocation %ǰԵ����ά�����洢����
        TailEdgeLocation %��Ե����ά�����洢����
        SpanWiseLocation %
        Chord
        RoateAngle % Ťת�Ƕ�(deg) ��ŤתΪ+ֵ����Ťת��-ֵ
        data
    end
    
    methods
        function obj=AirFoil(name,up,down)
            if nargin==0  %��������
                obj.name=[]; % �ַ���
                obj.LeadEdgeLocation=[]; %ǰԵ����ά�����洢����
                obj.TailEdgeLocation=[]; %��Ե����ά�����洢����
                obj.SpanWiseLocation=[]; %
                obj.Chord=[];
                obj.RoateAngle=[]; % Ťת�Ƕ�(deg) ��ŤתΪ+ֵ����Ťת��-ֵ
                obj.data=[];
            else
                if norm(up(1,2)-down(1,2))+norm(up(end,2)-down(end,2))>=1e-5
                    error('airfoil wrong!up and down can not get a airfoil!')
                end
                
                % adjust the inputted up and down matrix
                obj.name=name;
                if size(up,1)==3
                    up=up';
                end
                if size(down,1)==3
                    down=down';
                end
                
                % ��ͼ ����ʹ��
                % figure
                % hold off
                % plot(up(:,1),up(:,3))
                % hold on
                % plot(down(:,1),down(:,3))
                % axis equal

                % ����ǰ��Ե���ʽ��е���

                % ���ȵ�������
                [~,index]=sort(up(:,1),'ascend');
                up = up(index,:);

                [~,index]=sort(down(:,1),'ascend');
                down = down(index,:);

                if norm(up(1,:)-down(1,:))<1e-6 % ����ܽ� ��Ϊ����ɢ���
                    up(1,:) = down(1,:);
                else % ��ϵõ��µ�ǰԵ
                    % ���
                    [x,z] = GetTwoLineCrossPoints({[up(1,1),up(1,3)],[up(2,1),up(2,3)]},...
                        {[down(1,1),down(1,3)],[down(2,1),down(2,3)]});
                    % ����
                    up=[x,up(1,2),z;up];
                    down=[x,down(1,2),z;down];
                end

                if norm(up(end,:)-down(end,:))<1e-6
                    up(end,:) = down(end,:);
                else % ��ϵõ��µĺ�Ե
                    % ���
                    [x,z] = GetTwoLineCrossPoints({[up(end,1),up(end,3)],[up(end-1,1),up(end-1,3)]},...
                        {[down(end,1),down(end,3)],[down(end-1,1),down(end-1,3)]});
                    % ����
                    up=[up;x,up(end,2),z];
                    down=[down;x,down(end,2),z];
                end

                
                
                % get the lead tail location and chord 
                LeadEdgeIndex=find(up(:,1)==min(up(:,1)),1);
                TailEdgeIndex=find(up(:,1)==max(up(:,1)),1);
                obj.TailEdgeLocation=up(TailEdgeIndex,:);
                obj.LeadEdgeLocation=up(LeadEdgeIndex,:);
                
                obj.SpanWiseLocation=up(LeadEdgeIndex,2);
                obj.Chord=norm(obj.TailEdgeLocation-obj.LeadEdgeLocation);

                % get roate angle (/deg)
                obj.RoateAngle=atan((obj.LeadEdgeLocation(3)-obj.TailEdgeLocation(3))/(obj.TailEdgeLocation(1)-obj.LeadEdgeLocation(1)))/pi*180;
                % merge the up and down data
                obj.data=[];
                [~,index]=sort(up(:,1),'descend');
                for i=1:numel(index)
                    obj.data(end+1,:)=up(index(i),:);
                end
                
                [~,index]=sort(down(:,1),'ascend');
                for i=2:numel(index)
                    obj.data(end+1,:)=down(index(i),:);
                end
                
                
                
                
                % ������������
                theta=obj.RoateAngle/180*pi;
                R=[cos(theta),0,-sin(theta);...
                    0,1,0;...
                    sin(theta),0,cos(theta)];
                for i=1:size(obj.data,1)
                    obj.data(i,:)=obj.data(i,:)-obj.LeadEdgeLocation;
                    obj.data(i,:)=obj.data(i,:)*(R');
                end
                

                
                
            end
            
        end
        
        function AdjustAntiClock(obj)
            % ���������ϵĵ�˳��Ϊ��ʱ��
            % �˺�����ʱ����
            k_up=(obj.data(floor(size(obj.data,1)/8),3)-obj.data(1,3))/(obj.data(floor(size(obj.data,1)/8),1)-obj.data(1,1));
            k_down=(obj.data(end-floor(size(obj.data,1)/8),3)-obj.data(1,3))/(obj.data(end-floor(size(obj.data,1)/8),1)-obj.data(1,1));
            if k_down<k_up
                old_data=obj.data;
                for i=1:size(old_data,1) 
                    obj.data(i,:)=old_data(size(old_data,1)-i+1,:);
                end
                
            end
            
            
      
        end
        
        
        
        
        function OutputAirfoilDatFile(obj,N)
            %% ��������ļ�
            % N ��ʾN������ѡһ����Ĭ��ȫѡ
          
            
            if nargin==1
                

                file=fopen("./output/"+strcat(obj.name,'.dat'),'w');
                fprintf(file,'%s',obj.name);
                for i=1:size(obj.data,1)
                    fprintf(file,'\n');
                    fprintf(file,'%d %d',(obj.data((i),1))/obj.Chord,(obj.data((i),3))/obj.Chord);
                end
                fclose(file);
            else
                index=linspace(1,size(obj.data,1),floor(size(obj.data,1)/N));
                index=floor(index);
                file=fopen(strcat(obj.name,'.dat'),'w');
                fprintf(file,'%s',obj.name);
                for i=1:numel(index)
                    fprintf(file,'\n');
                    
                    fprintf(file,'%d %d',(obj.data(index(i),1))/obj.Chord,(obj.data(index(i),3))/obj.Chord);
                end
                fclose(file);
                
            end
            
        end
        
        function Plot(obj)
            % ��������
            figure
            axis equal;
            pause(0.5)
            timepause=2/size(obj.data,1);
            
            for i=2:size(obj.data,1)
                hold on
                plot([obj.data(i-1,1),obj.data(i,1)],[obj.data(i-1,3),obj.data(i,3)],'k')
                pause(timepause);
            end
            
            plot([obj.LeadEdgeLocation(1) obj.TailEdgeLocation(1)],[obj.LeadEdgeLocation(3) obj.TailEdgeLocation(3)],'r.','MarkerSize',30)
        end
        
        function exam(obj)
            k=NaN*ones(size(obj.data,1)-1,1);%б��
           for i=1:(size(obj.data,1)-1)
               k(i)=(obj.data(i+1,3)-obj.data(i,3))/(obj.data(i+1,1)-obj.data(i,1))    ;
           end
           d_k=diff(k);
           plot(1:numel(d_k),d_k);   
        end
        
    end
end



