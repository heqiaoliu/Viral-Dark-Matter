function refreshpanel(this)
% Updates contents when it becomes visible or configuration changes.

%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $ $Date: 2008/12/04 22:21:57 $

ConfigData = this.ConfigData;

%% Refresh Diagram Axes
this.refreshDiagram;


%% Refresh Sign Table Data

for ct = 1:length(ConfigData.FeedbackSign)
    if isequal(ConfigData.FeedbackSign(ct),1)
        FeedbackStr = '+1';
    else
        FeedbackStr = '-1';
    end
    FeedbackSignData(ct,:) = {['S',num2str(ct)],FeedbackStr};
end

this.TableModels.SignTableModel.setData(FeedbackSignData);


%% Refresh Blocks and Signals Table Data


util = slcontrol.Utilities;
BlocksAndSignalData = LocalGetBlocksAndSignalsData(this);

this.TableModels.BlocksAndSignalsTableModel.setData(matlab2java(util,BlocksAndSignalData));





%%
function Data = LocalGetBlocksAndSignalsData(this)
% Create Data for Table
ConfigData = this.ConfigData;
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


