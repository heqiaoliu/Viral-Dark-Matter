function ParamSpec = createParamSpec(this)
% getParameterSpec  Gets the parameter spec forthe pz group

%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2006/09/30 00:16:54 $


if isempty(this.Pole)
    str = 'Zero';
    value = [real(this.Zero(1));imag(this.Zero(1))];
else
    str = 'Pole';
    value = [real(this.Pole(1));imag(this.Pole(1))];
end


PID = modelpack.STParameterID(...
    sprintf('Complex %s (group %d)',str,find(this==this.Parent.PZGroup)), ...
    [2,1], ...
    this.Parent.Identifier, ...
    'double', ...
    {''}, ...
    sprintf('Complex %s',str));
ParamSpec              = modelpack.STParameterSpec(PID,{'Real/Imag','Zeta/Wn'});
ParamSpec.Known        = true;
ParamSpec.Minimum      = [-inf; 0];
ParamSpec.Maximum      = [inf; inf];
ParamSpec.InitialValue = value;
ParamSpec.TypicalValue = value;

ParamSpec.Listeners = handle.listener(this,this.findprop('Format'),...
    'PropertyPostSet',@(hSrc,hData) LocalSetMinMax(ParamSpec));


%% LOCAL FUNCTIONS --------------------------------------------------------
function LocalSetMinMax(ParamSpec)
if ParamSpec.Format == 1
    ParamSpec.Minimum = [-inf; 0];
    ParamSpec.Maximum = [inf; inf];
else
   
    ParamSpec.Minimum = [-1 ; 0 ];
    ParamSpec.Maximum = [1; inf];
end