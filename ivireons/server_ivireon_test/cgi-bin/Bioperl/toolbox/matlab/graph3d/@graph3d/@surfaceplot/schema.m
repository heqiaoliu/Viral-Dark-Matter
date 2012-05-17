function schema

%   Copyright 1984-2005 The MathWorks, Inc. 
%   $Revision $  $Date: 2007/05/29 21:13:54 $

pkg = findpackage('graph3d');
hgpkg = findpackage('hg');
hBaseClass = findclass(hgpkg,'surface');

% define class
hClass = schema.class(pkg,'surfaceplot',hBaseClass);

% Get XData,YData,CData property objects for listeners
hProp = [findprop(hBaseClass,'XData'), ...
         findprop(hBaseClass,'YData'), ...
         findprop(hBaseClass,'CData')];
hPropList = hProp;

% XDataMode
hProp = schema.prop(hClass,'XDataMode','axesXLimModeType');
hProp.FactoryValue = 'Auto';
hPropList(end+1) = hProp;

% XDataSource
hProp = schema.prop(hClass,'XDataSource','string');
hProp.Description = 'Independent variable source';
hPropList(end+1) = hProp;

% YDataMode
hProp = schema.prop(hClass,'YDataMode','axesXLimModeType');
hProp.FactoryValue = 'Auto';
hPropList(end+1) = hProp;

% YDataSource
hProp = schema.prop(hClass,'YDataSource','string');
hProp.Description = 'Independent variable source';
hPropList(end+1) = hProp;

% CDataMode
hProp = schema.prop(hClass,'CDataMode','axesXLimModeType');
hProp.FactoryValue = 'Auto';
hPropList(end+1) = hProp;

% CDataSource
hProp = schema.prop(hClass,'CDataSource','string');
hProp.Description = 'Independent variable source';
hPropList(end+1) = hProp;

% ZData
hProp = findprop(hBaseClass,'ZData');
hPropList(end+1) = hProp;

% ZData Source
hProp = schema.prop(hClass,'ZDataSource','string');
hProp.Description = 'Independent variable source';
hPropList(end+1) = hProp;

% Store property objects so that we don't have to make an
% expencive call to findprop in the constructor.
hProp = schema.prop(hClass,'InternalPropertyHandles','MATLAB array');
hProp.Visible = 'off';
hProp.AccessFlags.Serialize = 'off';
hProp.AccessFlags.PublicSet = 'off';
hProp.AccessFlags.PublicGet = 'off';
hProp.FactoryValue = hPropList;

hProp = schema.prop(hClass,'InternalListener','handle');
hProp.AccessFlags.Serialize = 'off';
hProp.Visible = 'off';