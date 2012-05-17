function schema
%SCHEMA  Defines properties for @pzview class

%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:21:14 $
superclass = findclass(findpackage('wrfc'), 'view');
c = schema.class(findpackage('resppack'), 'hsvview', superclass);

% Class attributes
schema.prop(c, 'FiniteSV', 'handle');    % bar chart for finite HSV (blue)
schema.prop(c, 'InfiniteSV', 'handle');  % bar chart for infinite HSV (red)
