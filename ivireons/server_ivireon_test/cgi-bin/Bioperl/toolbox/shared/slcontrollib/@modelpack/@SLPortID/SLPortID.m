function this = SLPortID(name, dims, path, type, portno)
% SLPORTID Constructor
%
% h = modelpack.SLPortID(name, dims, [path], [type], [portno])
%
% where
% path, type, portno are optional arguments or are set to [] for defaults.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:24:37 $

% Create object
this = modelpack.SLPortID;

% No argument constructor call
ni = nargin;
if ni == 0
  return
end

% Default arguments
if (ni < 3 || isempty(path)),   path   = '';       end
if (ni < 4 || isempty(type)),   type   = 'Output'; end
if (ni < 5 || isempty(portno)), portno = NaN;      end

% Set properties
this.Version    = 1.0;
this.Name       = name;
setDimensions(this, dims);
this.Path       = path;
this.Type       = type;
this.PortNumber = portno;
