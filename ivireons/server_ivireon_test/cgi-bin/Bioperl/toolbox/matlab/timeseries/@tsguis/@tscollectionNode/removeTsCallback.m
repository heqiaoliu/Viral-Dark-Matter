function removeTsCallback(this,tsName)
%Remove the selected timeseries from the tscollection
% This is called as a response to requests from popupschema- remove
% timeseries or remove button for tscollection members on tscollectionNode
% panel. 

%   Copyright 2005-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2007/12/14 14:55:58 $

%% Remove ts in response to callback

%Record the remove-ts transaction
T = tsguis.nodetransaction;
recorder = tsguis.recorder;
tsc = {};
if nargin<2
    selectedRows = this.Handles.membersTable.getSelectedRows+1;
    tsName = {};
    tsNode = {};
    for k = 1:length(selectedRows)
        selRow = selectedRows(k);
        if selRow>0
            thistableData = cell(this.Handles.membersTable.getModel.getData);
            tsName{end+1} = thistableData{selRow,1}; %#ok<AGROW>
            tsNode{end+1} = this.getChildren('Label',tsName{end}); %#ok<AGROW>
        end
    end
elseif iscell(tsName)
    tsNode = cell(1,length(tsName));
    for k = 1:length(tsName)
        tsNode{k} = this.getChildren('Label',tsName{k});
    end
else
    error('tscollectionNode:removeTsCallback:invNameArray',...
        'A cell array of time series names is expected for second input ''tsName''.');
end

for k = 1:length(tsName)
    if ~isempty(tsNode{k})
        tsc{end+1} = this.getTimeSeries(tsName{k});
        this.Tscollection.removets(tsName{k});
        if strcmp(recorder.Recording,'on')
            T.addbuffer(xlate('%% Delete tscollection member'));
            T.addbuffer(['removets(',this.Tscollection.Name,', ''',tsName{k},''');']);
        end
    end
end

if ~isempty(tsc)
    T.ObjectsCell = tsc; %a cell array of timeseries members
    T.Action = 'removed';
    T.ParentNodeHandle = this;

    %% Store transaction
    T.commit;
    recorder.pushundo(T);
end
