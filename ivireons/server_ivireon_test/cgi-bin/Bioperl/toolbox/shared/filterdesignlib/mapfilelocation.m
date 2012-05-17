function mfl = mapfilelocation(toolboxName)
%MAPFILELOCATION Returns the map file location.
%   MAPFILELOCATION(TBX) Returns the map file location for the toolbox TBX.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/10/18 03:15:52 $

mfl = fullfile(docroot, 'toolbox', toolboxName, [toolboxName '.map']);

% [EOF]
