function this = MLPortID(model, name, dims, type)
% MLPORTID Constructor
%
% h = modelpack.MLPortID(name, dims, [type])
%
% where
% type is an optional argument or is set to [] for default.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:23:04 $

% Create object
this = modelpack.MLPortID;

% No argument constructor call
if nargin == 0
  return
end

% Default arguments
if (nargin < 3 || isempty(type)), type = 'Output'; end

% Set properties
this.Version = 1.0;

this.Name    = name;
setDimensions(this, dims);
this.Type    = type;
