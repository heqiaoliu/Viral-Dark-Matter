function schema
% SCHEMA Class definition for @SinestreamSource

% Author(s): Erman Korkut 23-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/04/21 04:49:45 $

% Find parent package
pkg = findpackage('frestviews');
% Register class
superclass = findclass(findpackage('frestviews'),'SimviewSource');
c = schema.class(pkg, 'SimcompareSource', superclass);
% Class attributes
schema.prop(c, 'LinearOutput', 'MATLAB array');