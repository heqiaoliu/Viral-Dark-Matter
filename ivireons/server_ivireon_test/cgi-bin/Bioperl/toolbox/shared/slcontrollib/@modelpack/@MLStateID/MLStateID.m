function this = MLStateID(model, name, dims, Ts)
% MLSTATEID Constructor
%
% h = modelpack.MLState(model, name, dims, [Ts])
%
% where
% Ts is an optional argument or is set to [] for default.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/12/22 18:53:27 $

% Create object
this = modelpack.MLStateID;

% No argument constructor call
if nargin == 0
  return
end

% Default arguments
if (nargin < 4 || isempty(Ts)), Ts = 0.0; end

% Set properties
this.Version = 1.0;

this.Name    = name;
setDimensions(this, dims);
this.Ts      = Ts;
