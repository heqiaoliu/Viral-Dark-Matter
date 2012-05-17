function obj = simplematlabpooljob(proxy)
; %#ok Undocumented
%SIMPLEMATLABPOOLJOB Abstract constructor for this class

% Copyright 2007 The MathWorks, Inc.

% $Revision: 1.1.6.1 $    $Date: 2007/10/10 20:41:38 $

obj = distcomp.simplematlabpooljob;

obj.abstractjob(proxy);

% This class accepts configurations and uses the paralleljob section.
sectionName = 'paralleljob';
obj.pInitializeForConfigurations(sectionName);
