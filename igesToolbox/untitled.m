% Load parameter data from IGES-file.

[ParameterData,EntityType,numEntityType,unknownEntityType,numunknownEntityType]=iges2matlab('x56_aero.IGS');


% Plot the IGES object
plotIGES(ParameterData,2,1,30);