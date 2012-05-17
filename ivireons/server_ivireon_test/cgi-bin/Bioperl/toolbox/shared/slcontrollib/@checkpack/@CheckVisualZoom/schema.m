function schema

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/05/10 17:38:08 $

%% Class Definition
%
% Extension for check block visualizations to implement zoom.
%
% Note: the class is subclassed from scopeextensions.PlotNavigator, so that
% the toolbar button placement and autoscale algorithms can be overloaded
hParentPkg = findpackage('scopeextensions');
hParent    = findclass(hParentPkg, 'PlotNavigation');
hPackage   = findpackage('checkpack');
hThisClass = schema.class(hPackage, 'CheckVisualZoom', hParent);

extmgr.registerExtensionMethods(hThisClass);
end