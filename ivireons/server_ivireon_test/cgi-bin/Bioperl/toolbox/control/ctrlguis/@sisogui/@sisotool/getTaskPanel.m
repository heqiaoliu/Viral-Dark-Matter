function Panel = getTaskPanel(this)
% getTaskPanel


%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:53:19 $



if isempty(this.DesignTask)
   % Create dialog object
   h = sisogui.SISODesignTask(this); 
   % Build dialog UI
   this.DesignTask = h;
end

Panel = this.DesignTask.Handles.TaskMainPanel;