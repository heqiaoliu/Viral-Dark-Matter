function ParamSpec = createParamSpec(this)
% CREATEPARAMSPEC Creates the parameters spec for lead lag group.
%

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2006/09/30 00:16:55 $


PID = modelpack.STParameterID(...
    sprintf('LeadLag (group %d)',find(this==this.Parent.PZGroup)), ...
    [2,1], ...
    this.Parent.Identifier, ...
    'double', ...
    {''},...
    sprintf('LeadLag'));
ParamSpec = modelpack.STParameterSpec(PID,{'Zero/Pole','PhaseMax/Wmax'});
    ParamSpec.Minimum = [-inf;-inf];
    ParamSpec.Maximum = [inf;inf];

ParamSpec.Known = true;
ParamSpec.InitialValue = [this.Zero;this.Pole];

ParamSpec.TypicalValue = [this.Zero;this.Pole];

ParamSpec.Listeners = handle.listener(this,this.findprop('Format'),...
    'PropertyPostSet',@(hSrc,hData) LocalSetMinMax(ParamSpec));


%% LOCAL FUNCTIONS --------------------------------------------------------
function LocalSetMinMax(ParamSpec)
if ParamSpec.Format == 1
    ParamSpec.Minimum = [-inf;-inf];
    ParamSpec.Maximum = [inf;inf];
else
    maxphase = asin(1-eps);
    ParamSpec.Minimum = [-maxphase ; 0 ];
    ParamSpec.Maximum = [maxphase; Inf];
end