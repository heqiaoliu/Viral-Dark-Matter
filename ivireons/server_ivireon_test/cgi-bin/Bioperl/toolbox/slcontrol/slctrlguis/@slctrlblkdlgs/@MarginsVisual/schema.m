function schema 
% SCHEMA Define the Margins visualization class
%
 
% Author(s): A. Stothert
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/03/31 18:59:41 $

scls = findclass(findpackage('slctrlblkdlgs'),'absFrequencyVisual');
pk = findpackage('slctrlblkdlgs');
cls = schema.class(pk,'MarginsVisual',scls);

% All subclasses need to register the extension methods, otherwise the static methods of the super class will
% not be invoked. 
extmgr.registerExtensionMethods(cls);

%Subclass properties
if isempty( findtype('slctrlblkdlgs_enumGPMPlotType') )
   schema.EnumType('slctrlblkdlgs_enumGPMPlotType',{'bode', 'nichols', 'nyquist', 'table'});
end
schema.prop(cls,'PlotType','slctrlblkdlgs_enumGPMPlotType');