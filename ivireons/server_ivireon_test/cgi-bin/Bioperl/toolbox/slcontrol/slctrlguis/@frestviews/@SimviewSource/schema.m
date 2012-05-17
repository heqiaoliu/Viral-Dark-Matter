function schema
% SCHEMA Class definition for @SimviewSource

% Author(s): Erman Korkut 12-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2009/04/21 04:50:01 $

% Find parent package
pkg = findpackage('frestviews');
% Register class
superclass = findclass(findpackage('wrfc'),'datasource');
c = schema.class(pkg, 'SimviewSource', superclass);
% Class attributes
schema.prop(c, 'Input', 'MATLAB array');
schema.prop(c, 'Output', 'MATLAB array');

