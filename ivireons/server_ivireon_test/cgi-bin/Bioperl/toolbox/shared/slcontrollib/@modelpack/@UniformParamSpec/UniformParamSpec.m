function this = UniformParamSpec(ID)
% UNIFORMPARAMSPEC Constructor for a uniform random parameter spec
%
% h = modelpack.UniformParamSpec(parameterID);
% 
% Inputs:
%    parameterID a modelpack.ParameterID object.
%

% Author(s): A. Stothert
% Revised:
% Copyright 2004-2007 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/09/18 02:29:16 $

% Create object
this = modelpack.UniformParamSpec;

% No argument constructor call
ni = nargin;
if (ni == 0)
  return
end

if (ni < 1) || ~isa(ID, 'modelpack.ParameterID')
  ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','ID','modelpack.ParameterID')
end

% Set invariant properties
this.Name    = ID.getFullName;
this.ID      = ID;
this.Version = 1.0;