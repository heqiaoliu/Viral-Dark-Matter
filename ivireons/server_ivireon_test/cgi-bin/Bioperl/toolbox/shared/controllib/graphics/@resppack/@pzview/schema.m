function schema
%SCHEMA  Defines properties for @pzview class

%  Author(s): Bora Eryilmaz
%  Revised:   Kamesh Subbarao
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:23:08 $

% Register class
superclass = findclass(findpackage('wrfc'), 'view');
c = schema.class(findpackage('resppack'), 'pzview', superclass);

% Class attributes
schema.prop(c, 'PoleCurves', 'MATLAB array');  % Handles of HG lines (matrix)
schema.prop(c, 'ZeroCurves', 'MATLAB array');  % Handles of HG lines (matrix)
