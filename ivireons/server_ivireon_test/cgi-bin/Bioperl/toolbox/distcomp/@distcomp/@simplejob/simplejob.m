function obj = simplejob(proxy)
; %#ok Undocumented
%SIMPLEJOB abstract constructor for this class
%
%  OBJ = SIMPLEJOB(PROXY)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.4 $    $Date: 2007/06/18 22:13:56 $

obj = distcomp.simplejob;

obj.abstractjob(proxy);

% This class accepts configurations and uses the job section.
sectionName = 'job';
obj.pInitializeForConfigurations(sectionName);
