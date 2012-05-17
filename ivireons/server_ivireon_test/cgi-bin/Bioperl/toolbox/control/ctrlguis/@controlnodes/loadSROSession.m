function loadSROSession(SISODesignTask,varargin) 
% LOADSISOTOOL  package method to load SRO sisotool session
%
 
% Author(s): A. Stothert 02-Nov-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/01/26 01:45:57 $

if ~isempty(SISODesignTask.SaveData.sropnlSession)
   %Find and restore sro panel settings
   node = SISODesignTask.down;
   while ~isempty(node)
      if isa(node,'srosisotoolgui.sropnl')
         %Found SRO node, set saved data
         node.SaveData = SISODesignTask.SaveData.sropnlSession;
         %Force node update and redraw
         [junk,morejunk,manager] = slctrlexplorer;
         node.getDialogInterface(manager);
         node = [];
      else
         node = node.right;
      end
   end
end