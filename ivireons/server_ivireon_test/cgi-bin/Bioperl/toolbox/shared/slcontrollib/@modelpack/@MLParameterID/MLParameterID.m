function this = MLParameterID(model, name, dims, class)
% MLPARAMETERID Constructor
%
% h = modelpack.MLParameterID(model, name, dims, [class])
%
% where
% class is an optional argument or is set to [] for default.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:37:32 $

% Create object
this = modelpack.MLParameterID;

% No argument constructor call
if nargin == 0
  return
end

% Default arguments
if (nargin < 4 || isempty(class)), class = 'double'; end

% Set invariant properties
this.Version = 1.0;

% Set public properties
this.Name    = name;
setDimensions(this, dims);
this.Class   = class;
