function updateSummary(this, DialogPanel)
% UPDATESUMMARY  Update the text field with the snapshot summary
%
 
% Author(s): John W. Glass 16-Aug-2005
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 21:31:14 $

%% Get the summary area handle
sa = DialogPanel.getSummaryPanel;

%% Set the callback
h = handle(sa.getEditor, 'callbackproperties');
h.HyperlinkUpdateCallback = {@LocalEvaluateHyperlinkUpdate};

%% Define the default font type
textstr = '<font face=sans-serif SIZE=3>';

%% Label
data = {sprintf(['<B><FONT FACE=sans-serif SIZE=4 COLOR=#800000>Operating ',...
                    'Point Snapshot Summary</FONT></B><BR>'])};
data{end+1} = '<BR>';
data{end+1} = sprintf('%s&nbsp;-&nbsp; This operating point was captured when linearizing the model %s at t = %d.<BR>',textstr,this.OpPoint.Model,this.OpPoint.Time);
data{end+1} = '<BR>';
data{end+1} = sprintf('&nbsp;-&nbsp; The states listed in the <B>States</B> tab contain only the double valued continuous or discrete states in the model.<BR>');    
data{end+1} = '<BR>';

%% Add the new text
sa.setContent([data{:}]);