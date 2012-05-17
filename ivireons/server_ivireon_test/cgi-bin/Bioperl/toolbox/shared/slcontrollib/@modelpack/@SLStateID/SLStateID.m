function this = SLStateID(name, dims, path, Ts)
% SLSTATEID Constructor
%
% h = modelpack.SLState(name, dims, [path], [Ts])
%
% where
% path, Ts are optional arguments or are set to [] for defaults.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:24:53 $

% Create object
this = modelpack.SLStateID;

% No argument constructor call
ni = nargin;
if ni == 0
  return
end

% Default arguments
if (ni < 3 || isempty(path)), path = '';  end
if (ni < 4 || isempty(Ts)),   Ts   = 0.0; end

% Set properties
this.Version = 1.0;
this.Name    = name;
setDimensions(this, dims);
this.Path    = path;
this.Ts      = Ts;
