function PV = evalParameters(this, names)
% EVALPARAMETERS Evaluates model parameters in appropriate workspaces.
%
% NAMES can contain expressions such as: K, P(2), C{3}, S.a(1), etc.
%
% PV is a struct array with fields: Name, Value, and Workspace.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2009/12/22 18:57:49 $

utils = slcontrol.Utilities;
model = this.Name;

PV = utils.evalParameters(model, names);
end