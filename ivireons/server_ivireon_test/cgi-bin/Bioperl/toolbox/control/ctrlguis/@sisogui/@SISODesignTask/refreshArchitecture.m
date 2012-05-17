function refreshArchitecture(this)
% refreshArchitecture Refresh Architecture panel

%   Author(s): C. Buhr
%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2008/12/04 22:23:18 $


if isempty(this.Architecture)
    %Revisit
    this.Architecture = sisogui.SystemConfig(this.Parent);
    this.Handles.ArchitectureTab.add(this.Architecture.Handles.Panel,java.awt.BorderLayout.CENTER);
else
   % this.AnalysisPlotConfig.refreshPanel;
end
