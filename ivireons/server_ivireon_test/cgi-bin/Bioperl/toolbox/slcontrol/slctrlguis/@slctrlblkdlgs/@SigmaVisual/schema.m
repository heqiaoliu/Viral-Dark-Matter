function schema 
% SCHEMA Define the Sigma visualization class
%
 
% Author(s): A. Stothert
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:56:26 $

scls = findclass(findpackage('slctrlblkdlgs'),'absFrequencyVisual');
pk = findpackage('slctrlblkdlgs');
cls = schema.class(pk,'SigmaVisual',scls);

% All subclasses need to register the extension methods, otherwise the static methods of the super class will
% not be invoked. 
extmgr.registerExtensionMethods(cls);

%Subclass properties