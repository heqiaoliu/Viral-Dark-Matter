function ParamSpec = createParamSpec(this)
% CREATEPARAMSPEC Creates parameter spec for notch group

%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2006/09/30 00:16:56 $

PID = modelpack.STParameterID(...
    sprintf('Notch (group %d)',find(this==this.Parent.PZGroup)), ...
    [3,1], ...
    this.Parent.Identifier, ...
    'double', ...
    {''},...
    sprintf('Notch'));
ParamSpec = modelpack.STParameterSpec(PID,{'Wn,Zz,Zp'});

ParamSpec.Known        = true;
ParamSpec.InitialValue = this.getValue;
ParamSpec.TypicalValue = ParamSpec.InitialValue;
ParamSpec.Minimum      = [0; -1; -1];
ParamSpec.Maximum      = [Inf; 1; 1];