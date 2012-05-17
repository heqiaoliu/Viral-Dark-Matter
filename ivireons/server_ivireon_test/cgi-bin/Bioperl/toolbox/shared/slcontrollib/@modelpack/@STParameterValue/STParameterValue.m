function this = STParameterValue(parameterID) 
% STPARAMETERVALUE  constructor for SISOTOOL parameter value object
%
% This constructor takes a parameter identifier object and an optional
% subscripted name to create a PARAMETERVALUE object.
%
% h = modelpack.STParameterValue(parameterID);
%
% PARAMETERID a STParameterID object.


% Author(s): A. Stothert 06-Apr-2007
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/12/14 15:01:51 $

% Create object
this = modelpack.STParameterValue;

% No argument constructor call.
ni = nargin;
if (ni == 0)
  return
end

% Set properties.
this.Version = 1.0;
this.setID(parameterID); %Sets the name property
