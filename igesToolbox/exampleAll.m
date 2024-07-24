
% Compile the c-files
% makeIGESmex;

close all

igesIND=1;

switch igesIND
    case 1
        
        % Load parameter data from IGES-file.
        [ParameterData,EntityType,numEntityType,unknownEntityType,numunknownEntityType]=iges2matlab('IGESfiles/example.igs');
        
        % Plot the IGES object
        plotIGES(ParameterData,1);
        set(gca,'Clipping','off')
        
        light
        
        Ptrs=findEntityIGES(ParameterData,144);
        
        ind=10;
        
        fignr=2;
        plotIGESentity(ParameterData,Ptrs(ind),fignr);
        set(gca,'Clipping','off')
        
        nrbind=ParameterData{Ptrs(ind)}.pts;
        
        fignr=3;
        figure(fignr)
        plotNURBS(ParameterData{nrbind}.nurbs,[],90,60);
        set(gca,'Clipping','off')
        
    case 2
        
        % Load parameter data from IGES-file.
        [ParameterData,EntityType,numEntityType,unknownEntityType,numunknownEntityType]=iges2matlab('IGESfiles/piece.igs');
        
        % Plot the IGES object
        plotIGES(ParameterData,1);
        set(gca,'Clipping','off')
        
        light
        
        Ptrs=findEntityIGES(ParameterData,144);
        
        ind=10;
        
        fignr=2;
        plotIGESentity(ParameterData,Ptrs(ind),fignr),view(randn(3,1));
        set(gca,'Clipping','off')
        
        ind=2;
        
        viw=randn(3,1);
        
        fignr=3;
        plotIGESentity(ParameterData,Ptrs(ind),fignr),view(viw);
        set(gca,'Clipping','off')
        
        nrbind=ParameterData{Ptrs(ind)}.pts;
        
        fignr=4;
        figure(fignr)
        plotNURBS(ParameterData{nrbind}.nurbs,[],90,60),view(viw);
        set(gca,'Clipping','off')
        
    case 3
        
        % Load parameter data from IGES-file.
        [ParameterData,EntityType,numEntityType,unknownEntityType,numunknownEntityType]=iges2matlab('IGESfiles/srfOfRev.igs');
        
        % Plot the IGES object
        plotIGES(ParameterData,1);
        set(gca,'Clipping','off')
        light
        
        Ptrs=findEntityIGES(ParameterData,144);
        
        ind=10;
        
        viw=randn(3,1);
        
        fignr=2;
        plotIGESentity(ParameterData,Ptrs(ind),fignr),view(viw);
        set(gca,'Clipping','off')
        
        nrbind=ParameterData{Ptrs(ind)}.pts;
        
        fignr=3;
        figure(fignr)
        plotNURBS(ParameterData{nrbind}.nurbs,[],90,60),view(viw);
        set(gca,'Clipping','off')
        
end
