function schema
%SCHEMA  For abstract @estimator class.

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.10.4 $ $Date: 2008/10/02 18:52:55 $

% Get handles of associated packages.
hCreateInPackage = findpackage('idestimatorpack');

% Construct class.
c = schema.class(hCreateInPackage, 'estimator');

% Estimation project.
p = schema.prop(c, 'Model', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
      
% Estimation Data.
schema.prop(c, 'Data', 'MATLAB array');
%p.AccessFlags.PublicSet = 'off';

% Parameter info.
schema.prop(c, 'Info', 'MATLAB array');

% Optimization options (modified OPTIMSET structure).
schema.prop(c, 'Options', 'MATLAB array');
