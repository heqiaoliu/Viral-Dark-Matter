function Value = getParameterSpec(this)
% getParameterSpec  Gets the parameter spec forthe pz group

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:48:46 $

% Get param spec for pzgroup
if isempty(this.ParamSpec)
    this.ParamSpec = this.createParamSpec;
end

Value = this.ParamSpec;