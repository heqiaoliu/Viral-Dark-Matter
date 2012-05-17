function schema
%  SCHEMA  Defines properties for OperatingConditionSelectionPanel class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/12/22 19:09:12 $

% Find parent package
pkg = findpackage('OperatingConditions');

% Register class (subclass) in package
c = schema.class(pkg, 'OperatingConditionSelectionPanel');

% Properties
schema.prop(c, 'OpCondNode', 'MATLAB array');
schema.prop(c, 'Handles', 'MATLAB array');

% Listeners
schema.prop(c, 'OperatingConditionsListeners', 'MATLAB array');
