function assignParameters(this, PV)
% ASSIGNPARAMETERS Assigns model parameter values in appropriate workspace.
%
% PV is a structure array with fields: Name, Value, Workspace.
%
% NAME field can contain expressions such as: K, P(2), C{3}, S.a(1), etc.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2009/12/22 18:57:48 $

utils = slcontrol.Utilities;
utils.assignParameters(this.Name, PV);
end