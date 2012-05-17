function refreshManualTuning(this)

%   Author(s): C. Buhr
%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2008/12/04 22:23:24 $

if isempty(this.ManualTuning)
    this.ManualTuning = this.Parent.TextEditor(1);%sisogui.pzeditor(this.Parent.LoopData,this.Parent);
    this.ManualTuning.activate;
    this.ManualTuning.show(this.Parent.LoopData.C,1);
    this.Handles.ManualTuningTab.add(this.ManualTuning.Handles.Panel,java.awt.BorderLayout.CENTER);
else
    this.ManualTuning.refreshpanel;
end
