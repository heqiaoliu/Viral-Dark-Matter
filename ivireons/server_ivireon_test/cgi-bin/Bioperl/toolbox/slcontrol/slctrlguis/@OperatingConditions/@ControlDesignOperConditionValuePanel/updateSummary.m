function updateSummary(this, DialogPanel)
% UPDATESUMMARY  Update the text field with the snapshot summary
%
 
% Author(s): John W. Glass 16-Aug-2005
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2009/08/08 01:19:19 $

%% Get the summary area handle
sa = DialogPanel.getSummaryPanel;

%% Set the callback
h = handle(sa.getEditor, 'callbackproperties');
h.HyperlinkUpdateCallback = {@LocalEvaluateHyperlinkUpdate};

%% Define the default font type
textstr = '<font face=sans-serif SIZE=3>';

%% Label
str = ctrlMsgUtils.message('Slcontrol:operpointtask:OperatingPointSummaryTitle');
data = {sprintf('<B><FONT FACE=sans-serif SIZE=4 COLOR=#800000>%s</FONT></B><BR>',str)};
data{end+1} = sprintf('<BR>%s',textstr);
if ~isempty(this.SourceOpPointDescription)
    data{end+1} = sprintf('&nbsp;-&nbsp; %s.<BR>',this.SourceOpPointDescription);
    data{end+1} = '<BR>';
end

str = ctrlMsgUtils.message('Slcontrol:operpointtask:StateSummaryDescription');
data{end+1} = sprintf('&nbsp;-&nbsp; %s.<BR>',str);    
data{end+1} = '<BR>';
str = ctrlMsgUtils.message('Slcontrol:operpointtask:CreateNewOperatingPointInstruction');
data{end+1} = sprintf('&nbsp;-&nbsp; %s<BR>',str);              

%% Add the new text
sa.setContent([data{:}]);