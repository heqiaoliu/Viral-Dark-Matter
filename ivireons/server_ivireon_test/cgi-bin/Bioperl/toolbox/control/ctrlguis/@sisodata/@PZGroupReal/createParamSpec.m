function ParamSpec = createParamSpec(this)
% CREATEPARAMSPEC creates parameter spec for real group

%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2006/09/30 00:16:57 $



if isempty(this.Pole)
    str = 'Zero';
    value = this.Zero;
else
    str = 'Pole';
    value = this.Pole;
end


PID = modelpack.STParameterID(...
    sprintf('Real %s (group %d)',str, find(this==this.Parent.PZGroup)), ...
    [1,1], ...
    this.Parent.Identifier, ...
    'double', ...
    {''}, ...
    sprintf('Real %s',str));
ParamSpec = modelpack.STParameterSpec(PID);
ParamSpec.Minimum      = -inf;
ParamSpec.Maximum      = inf;
ParamSpec.InitialValue = value;
ParamSpec.Known        = true;
ParamSpec.TypicalValue = value;
