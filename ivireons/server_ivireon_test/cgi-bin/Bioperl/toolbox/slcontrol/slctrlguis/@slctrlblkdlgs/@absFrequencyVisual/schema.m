function schema 
% SCHEMA Define the parent class for all frequency domain visualizations
%
 
% Author(s): A. Stothert
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2010/04/30 00:44:24 $

scls = findclass(findpackage('checkpack'),'absCheckVisual');
pk = findpackage('slctrlblkdlgs');
cls = schema.class(pk,'absFrequencyVisual',scls);

% All subclasses need to register the extension methods, otherwise the static methods of the super class will
% not be invoked. 
extmgr.registerExtensionMethods(cls);

%Subclass properties
schema.prop(cls,'Listeners','mxArray');
schema.prop(cls,'ShowLegend','bool');