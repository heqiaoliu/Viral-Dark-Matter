function saveDesignNode(SISODesignTask,varargin) 
% SAVEDESIGNNODE  package method to set savedata property 
% for design nodes
%
 
% Author(s): A. Stothert 01-Nov-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2005/12/22 17:38:43 $

%Create save structure and populate with sisodb data
SISODesignTask.SaveData = struct(...
   'sisodbSession', SISODesignTask.sisodb.save, ...
   'sropnlSession', []);
if ishandle(SISODesignTask.sisodb.ResponseOptimization)
   %Have response optimization data, save it
   SISODesignTask.SaveData.sropnlSession = SISODesignTask.sisodb.ResponseOptimization.save;
end
