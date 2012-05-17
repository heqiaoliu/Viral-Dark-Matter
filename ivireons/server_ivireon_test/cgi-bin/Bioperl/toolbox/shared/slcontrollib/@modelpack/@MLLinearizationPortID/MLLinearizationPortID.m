function this = MLLinearizationPortID(model, name, dims, type)
% MLLINEARIZATIONPORTID Constructor
%
% h = modelpack.MLLinearizationPortID(model, name, dims, [type])
%
% where
% type is an optional arguments or is set to [] for default.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/12/22 18:53:05 $

% Create object
this = modelpack.MLLinearizationPortID;

% No argument constructor call
if nargin == 0
  return
end

% Default arguments
if (nargin < 4 || isempty(type)), type = 'Output'; end

% Set properties
this.Version    = 1.0;

this.Name       = name;
setDimensions(this, dims);
this.Type       = type;
