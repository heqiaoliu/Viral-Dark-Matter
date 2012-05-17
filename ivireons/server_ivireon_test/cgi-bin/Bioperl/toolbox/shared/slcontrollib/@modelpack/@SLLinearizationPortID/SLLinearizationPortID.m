function this = SLLinearizationPortID(name, dims, path, type, portno, openloop)
% SLLINEARIZATIONPORTID Constructor
%
% h = modelpack.SLLinearizationPortID(name, dims, [path], [type], [portno], [openloop])
%
% where
% path, type, portno, and openloop are optional arguments or are set to []
% for defaults.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2007 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/09/18 02:27:50 $

% Create object
this = modelpack.SLLinearizationPortID;

% No argument constructor call
if nargin == 0
  return
end

% Default arguments
if (nargin < 3 || isempty(path)),     path   = '';       end
if (nargin < 4 || isempty(type)),     type   = 'Output'; end
if (nargin < 5 || isempty(portno)),   portno = NaN;      end
if (nargin < 6 || isempty(openloop)), openloop = false;  end

% Set properties
this.Version    = 1.0;

this.Name       = name;
setDimensions(this, dims);
this.Path       = path;
this.Type       = type;
this.PortNumber = portno;
this.OpenLoop   = openloop;
