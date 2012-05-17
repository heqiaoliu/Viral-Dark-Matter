function this = SLParameterID(name, dims, path, cls, locations)
% SLPARAMETERID Constructor
%
% h = modelpack.SLParameterID(name, dims, [path], [class], [locations])
%
% where
% path, class, locations are optional arguments or are set to [] for defaults.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:24:24 $

% Create object
this = modelpack.SLParameterID;

% No argument constructor call
ni = nargin;
if ni == 0
  return
end

% Default arguments
if (ni < 3 || isempty(path)),      path      = '';       end
if (ni < 4 || isempty(cls)),       cls       = 'double'; end
if (ni < 5 || isempty(locations)), locations = {};       end

% Set properties
this.Version    = 1.0;
this.Name       = name;
setDimensions(this, dims);
this.Path       = path;
this.Class      = cls;
this.Locations  = locations;
