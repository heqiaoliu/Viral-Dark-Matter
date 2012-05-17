function hPropDb = getPropertyDb
%GETPROPERTYDB Get the propertyDb.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/09/09 21:29:24 $

hPropDb = extmgr.PropertyDb;

% Define the different autoscale modes.
if isempty(findtype('AxesScaling'))
    schema.EnumType('AxesScaling', { ...
        'Manual', ...
        'Auto', ...
        'Once at stop'});
end

% Define the Y-axis anchors
if isempty(findtype('AutoscaleYAnchors'))
    schema.EnumType('AutoscaleYAnchors', {...
        'Top', ...
        'Center', ...
        'Bottom'});
end

% Define the X-axis anchors
if isempty(findtype('AutoscaleXAnchors'))
    schema.EnumType('AutoscaleXAnchors', {...
        'Left', ...
        'Center', ...
        'Right'});
end

hPropDb.add('YDataDisplay', 'mxArray', 80);
hPropDb.add('XDataDisplay', 'mxArray', 100);
hPropDb.add('AutoscaleMode', 'AxesScaling', 'Once at stop');
hPropDb.add('ExpandOnly', 'bool', true);

hPropDb.add('AutoscaleYAnchor', 'AutoscaleYAnchors', 'Center');
hPropDb.add('AutoscaleXAnchor', 'AutoscaleXAnchors', 'Center');

hPropDb.add('AutoscaleXAxis',  'bool', false);

% [EOF]
