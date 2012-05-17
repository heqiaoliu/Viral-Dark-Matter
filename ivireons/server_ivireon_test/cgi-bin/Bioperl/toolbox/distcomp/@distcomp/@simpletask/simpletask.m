function obj = simpletask(proxy)
; %#ok Undocumented
%SIMPLETASK abstract constructor for this class
%
%  OBJ = SIMPLETASK(OBJ, GROUP, LOCATION)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.4 $    $Date: 2007/06/18 22:14:03 $

obj = distcomp.simpletask;
obj.abstracttask(proxy);

% This class accepts configurations and uses the task section.
sectionName = 'task';
obj.pInitializeForConfigurations(sectionName);
