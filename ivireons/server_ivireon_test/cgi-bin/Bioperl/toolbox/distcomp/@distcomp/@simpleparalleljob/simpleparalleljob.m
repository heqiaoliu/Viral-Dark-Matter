function obj = simpleparalleljob(proxy)
; %#ok Undocumented
%SIMPLEJOB abstract constructor for this class
%
%  OBJ = SIMPLEJOB(PROXY)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.5 $    $Date: 2007/06/18 22:13:59 $

obj = distcomp.simpleparalleljob;

obj.abstractjob(proxy);

% This class accepts configurations and uses the paralleljob section.
sectionName = 'paralleljob';
obj.pInitializeForConfigurations(sectionName);
