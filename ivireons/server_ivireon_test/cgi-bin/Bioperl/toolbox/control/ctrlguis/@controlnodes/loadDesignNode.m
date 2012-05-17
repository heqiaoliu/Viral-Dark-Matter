function loadDesignNode(SISODesignTask,varargin) 
% LOADDESIGNNODE  package method to load design node from savedata 
% property
%
 
% Author(s): A. Stothert 01-Nov-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/01/26 01:45:55 $

% Load sisodb settings
controlnodes.loadSISOTool(SISODesignTask,SISODesignTask.SaveData.sisodbSession);
[junk,morejunk,manager] = slctrlexplorer;
SISODesignTask.getDialogInterface(manager);

% Ensure that the loopdata has the same name as the node name
SISODesignTask.sisodb.LoopData.Name = SISODesignTask.Label;

% Load any sro settings
controlnodes.loadSROSession(SISODesignTask);

