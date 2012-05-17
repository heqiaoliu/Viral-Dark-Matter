function refreshAutomatedTuning(this)

%   Author(s): R. Chen
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2008/12/04 22:23:20 $

if isempty(this.AutomatedTuning)
    this.AutomatedTuning = sisogui.AutomatedTuning(this.Parent.LoopData,this.Parent);
    this.Handles.AutomatedTuningTab.add(this.AutomatedTuning.getPanel,java.awt.BorderLayout.CENTER)
end

    
