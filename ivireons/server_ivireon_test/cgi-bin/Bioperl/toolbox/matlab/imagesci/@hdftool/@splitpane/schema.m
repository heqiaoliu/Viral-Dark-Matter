function schema
%SCHEMA   Define the SPLITPANE class.

%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2006/06/15 20:14:49 $

    pk = findpackage('hdftool');
    c  = schema.class(pk, 'splitpane');

    schema.prop(c, 'OldPosition',     'MATLAB array');
    schema.prop(c, 'Invalid',         'bool');
    schema.prop(c, 'NorthWest',       'MATLAB array');
    schema.prop(c, 'SouthEast',       'MATLAB array');
    schema.prop(c, 'LayoutDirection', 'MATLAB array');
    schema.prop(c, 'Dominant',        'MATLAB array');
    schema.prop(c, 'DividerWidth',    'double');
    schema.prop(c, 'DividerHandle',   'double');
    schema.prop(c, 'AutoUpdate',      'bool');
    schema.prop(c, 'Active',          'MATLAB array');
    schema.prop(c, 'Panel',           'double');
    schema.prop(c, 'DominantExtent',   'double');
    schema.prop(c, 'MinDominantExtent','double');
    schema.prop(c, 'MinNonDominantExtent','double');
    schema.prop(c, 'hFig',            'MATLAB array');
    schema.prop(c, 'Listeners',       'handle.listener vector'); ...

end
