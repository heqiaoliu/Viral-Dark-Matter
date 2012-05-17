function schema
%  SCHEMA  Defines properties for Views class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2005/03/31 16:43:35 $

%% Find parent package
pkg = findpackage('explorer');

%% Find parent class (superclass)
supclass = findclass(pkg, 'node');

%% Register class (subclass) in package
inpkg = findpackage('GenericLinearizationNodes');
c = schema.class(inpkg, 'ViewSettings', supclass);

%% Public attributes
p = schema.prop(c, 'LTIViewer', 'handle');        
p.AccessFlags.Serialize = 'off';

%% Listeners handles
p = schema.prop(c, 'LinearizationResultsListeners', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'ViewListener', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'TitleListener', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'PlotVisbilityListeners', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'DeleteViewListeners', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'DeleteListeners', 'MATLAB array');
p.AccessFlags.Serialize = 'off';

%% Handles to the current ltiplots
p = schema.prop(c, 'ViewHandles', 'MATLAB array');
p.AccessFlags.Serialize = 'off';

%% Table data 
schema.prop(c, 'PlotSetupTableData', 'MATLAB array');
schema.prop(c, 'VisibleResultTableData', 'MATLAB array');

p = schema.prop(c, 'PlotConfigurations','MATLAB array');
pc = cell(6,3);
for ct = 1:6
    pc{ct,1} = sprintf('Plot %d',ct);
    pc{ct,2} = 'None';
    pc{ct,3} = '';
end
p.FactoryValue = pc;

p = schema.prop(c, 'VisibleTableColumns', 'MATLAB array');
p.FactoryValue = cell(6,2);
p.AccessFlags.Serialize = 'off';

p = schema.prop(c, 'AnalysisResultPointers', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
