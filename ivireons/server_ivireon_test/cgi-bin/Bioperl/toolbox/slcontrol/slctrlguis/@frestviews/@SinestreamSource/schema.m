function schema
% SCHEMA Class definition for @SinestreamSource

% Author(s): Erman Korkut 12-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2009/04/21 04:50:07 $

% Find parent package
pkg = findpackage('frestviews');
% Register class
superclass = findclass(findpackage('frestviews'),'SimviewSource');
c = schema.class(pkg, 'SinestreamSource', superclass);
% Class attributes
schema.prop(c, 'FreqSwitchInd', 'MATLAB array');
schema.prop(c, 'SSSwitchInd', 'MATLAB array');
schema.prop(c, 'Ts', 'MATLAB array');
schema.prop(c, 'ShowFilteredOutput',    'on/off');  