function est = estimMetaData(est,plant,known,sensors)
% Sets I/O names and groups and state names for state observers
% (used by ESTIM and KALMAN).

%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.3 $  $Date: 2010/02/08 22:29:09 $

% Use default name uj if all plant inputs are unnamed
if isempty(plant.InputName_)
   Uname = strseq('u',known);
else
   Uname = plant.InputName_(known);
end
Nu = length(Uname);   

% Use default name yj if all plant outputs are unnamed
if isempty(plant.OutputName_)
   Yname = strseq('y',sensors);
else
   Yname = plant.OutputName_(sensors);
end
Ny = length(Yname);   

% Use default name xj if all plant states are unnamed
Xname = plant.StateName;  Nx = length(Xname);
if all(strcmp(Xname,'')),
   Xname = strseq('x',1:Nx);
end

% Gives names to estimated states and outputs by
% appending _e to state and measurement names
YeName = LocalAddSuffix(Yname);
XeName = LocalAddSuffix(Xname);
est.StateName = XeName;
est.InputName = [Uname ; Yname];
est.OutputName = [YeName ; XeName];

% Set input groups to 'KnownInput' and 'Measurement'
InputGroup = struct;
if Nu,
   InputGroup.KnownInput = 1:Nu;
end
if Ny,
   InputGroup.Measurement = Nu+1:Nu+Ny;
end
est.InputGroup = InputGroup;

% Set output groups to 'OutputEstimate' and 'StateEstimate'
OutputGroup = struct;
if Ny,
   OutputGroup.OutputEstimate = 1:Ny;
end
if Nx,
   OutputGroup.StateEstimate = Ny+1:Ny+Nx;
end
est.OutputGroup = OutputGroup;


%------------------
function Names = LocalAddSuffix(Names)
% Adds "_e" suffix to a set of input, output, or state names.
idx = find(~cellfun(@isempty,Names));
if ~isempty(idx)  % because STRCAT(cell(0,1),'_e') returns '_e'
   Names(idx) = strcat(Names(idx),'_e');
end
