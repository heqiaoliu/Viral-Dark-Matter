function this = ParameterSpec(parameterID, subsName)
% PARAMETERSPEC Constructor
%
% This constructor takes a parameter identifier object and an optional
% subscripted name to create a PARAMETERSPEC object.
%
% h = modelpack.ParameterSpec(parameterID, [subsName]);
%
% PARAMETERID a ParameterID object.
% SUBSNAME    is the optional subscripted parameter name; otherwise set to empty.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2007 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2007/12/14 15:01:23 $

% Create object
this = modelpack.ParameterSpec;

% No argument constructor call.
ni = nargin;
if (ni == 0)
  return
end

% Set the default value to empty.
if (ni < 2 || isempty(subsName)), subsName = parameterID.getName; end

% Set properties.
this.Version = 1.0;
this.setID(parameterID);
this.setName(subsName);

