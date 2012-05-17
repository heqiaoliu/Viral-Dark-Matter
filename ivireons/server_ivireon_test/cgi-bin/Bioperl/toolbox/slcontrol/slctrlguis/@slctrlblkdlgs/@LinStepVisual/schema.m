function schema 
% SCHEMA Define the Bode visualization class
%
 
% Author(s): A. Stothert
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:55:57 $

scls = findclass(findpackage('slctrlblkdlgs'),'absFrequencyVisual');
pk = findpackage('slctrlblkdlgs');
cls = schema.class(pk,'LinStepVisual',scls);

% All subclasses need to register the extension methods, otherwise the static methods of the super class will
% not be invoked. 
extmgr.registerExtensionMethods(cls);

%Subclass properties