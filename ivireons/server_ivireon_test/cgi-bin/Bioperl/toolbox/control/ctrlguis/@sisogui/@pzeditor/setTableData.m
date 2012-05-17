function setTableData(Editor,Data,idxC,Row)
%setTableData  Method to update the block parameters based on the input
%from java GUI. 

%   Author(s): R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2006/06/20 20:03:13 $

import java.lang.* java.awt.*;

%% if empty, return
Parameters = Editor.CompList(idxC).Parameters;
if isempty(Parameters)
    return
end

%% Find non-tunable/non-double parameters
indvalid = find(strcmp('on',{Parameters.Tunable}));
for ct = numel(indvalid):-1:1
    if ~strcmp('double',class(Parameters(indvalid(ct)).Value))
        indvalid(ct) = [];
    end
end

%% update block parameters
try
    EventMgr = Editor.Parent.EventManager;
    T = ctrluis.transaction(Editor.LoopData,'Name','Edit Parameter Value',...
        'OperationStore','on','InverseOperationStore','on');
    newValue = eval(Data(Row,2));
    Editor.CompList(idxC).setParameterValue(indvalid(Row),newValue);
    EventMgr.record(T);
    % Notify status and history listeners
    Status = sprintf('Modified Compensator Parameter.');
    EventMgr.newstatus(Status);
    EventMgr.recordtxt('history',Status);
catch
    T.Transaction.commit; % commit transaction before deleting wrapper
    delete(T);
    refresh_para_table(Editor);
    return
end

%% export the data
Editor.exportdata;
