function setTunedLoopTableData(this)

%   Author(s): C. Buhr
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2008/05/31 23:16:02 $

% Determine the entries that are open loop
tunedloops = this.SISODB.LoopData.L;
nloops = length(tunedloops);
FeedbackFlag = get(tunedloops,{'Feedback'});
isOpenLoop = [FeedbackFlag{:}];

% Create the summary table data
SummaryTableData = cell(numel(nloops),2);
for ct = 1:numel(isOpenLoop)
    SummaryTableData{ct,1} = tunedloops(ct).Name;
    SummaryTableData{ct,2} = tunedloops(ct).Description;
end

% Update the summary table.  This will update the available loop
% comboboxes.
if isequal(nloops,0)
    javaMethodEDT('setEnabled',this.Handles.TablePanel.getViewTable,false);
else
    SummaryTableDataJava = matlab2java(slcontrol.Utilities,SummaryTableData);
    % Update the view table data to include the first loop if there are
    % not any initial loops
    ViewTableData = cell(this.Handles.TablePanel.getViewTableModel.data);
    if any(strcmp(ViewTableData(:,2),'None'))
        for ct = 1:6
            ViewTableData{ct,2} = tunedloops(1).Name;
        end
    end
    AvailableLoopsJava = matlab2java1d(slcontrol.Utilities,SummaryTableData(:,1),'java.lang.String');
    ViewTableDataJava = matlab2java(slcontrol.Utilities,ViewTableData);
    
    % Send the data over to Java in one shot
    javaMethodEDT('setTableData',this.Handles.TablePanel,ViewTableDataJava,AvailableLoopsJava,SummaryTableDataJava,isOpenLoop);
end
