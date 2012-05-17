function schema 
% SCHEMA abstract class for all ltiplot based visualizations
%
 
% Author(s): A. Stothert
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:51:37 $

%Register class
scls = findclass(findpackage('uiscopes'),'AbstractVisual');
pk = findpackage('checkpack');
cls = schema.class(pk,'absCheckVisual',scls);

% All subclasses need to register the extension methods, otherwise the static methods of the super class will
% not be invoked. 
extmgr.registerExtensionMethods(cls);

%% Class properties
p = schema.prop(cls, 'hPlot', 'mxArray');          %handle to resppack.plot object
p.FactoryValue = [];
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'on';
p = schema.prop(cls, 'hMenu', 'mxArray');          %handles for plot context menus
p.FactoryValue = [];
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'on';
p = schema.prop(cls, 'SimResultLimit', 'double');  %Maximum number of simulation results to display
p.FactoryValue = 1;
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'on';
p = schema.prop(cls, 'SimResultCounter', 'double'); %Number of simulation results displayed
p.FactoryValue = 0;
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'off';
p = schema.prop(cls, 'EventManager', 'mxArray');    %Undo/Redo manager for visualization
p.FactoryValue = [];
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'off';
end