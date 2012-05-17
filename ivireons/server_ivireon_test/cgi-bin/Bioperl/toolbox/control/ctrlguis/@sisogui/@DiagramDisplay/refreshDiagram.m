function refreshDiagram(this)
% Updates tab contents when it becomes visible.

%   Authors: P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2005/12/22 17:41:34 $

cla(this.Handles.Axes)
ConfigData = this.Parent.exportdesign;
Diagram = loopstruct(this.Handles.Axes, ConfigData, 'labels',this.LoopConfig);

Data = LocalGetBlocksAndSignalsData(ConfigData);
this.Handles.TableModel.setData(Data);

function Data = LocalGetBlocksAndSignalsData(ConfigData)
% Create Data for Table
DefaultDesign = sisoinit(ConfigData.Configuration);

Tuned = ConfigData.Tuned;
Fixed = ConfigData.Fixed;
Blocks = [ConfigData.Tuned(:);ConfigData.Fixed(:)];

IDList =  [Blocks; DefaultDesign.Input(:); DefaultDesign.Output(:)];

for ct = 1:length(Blocks)
    Data{ct,1} = ConfigData.(Blocks{ct}).Name;
end

Data = [Data; ConfigData.Input(:); ConfigData.Output(:)];

Data = [IDList,Data];
