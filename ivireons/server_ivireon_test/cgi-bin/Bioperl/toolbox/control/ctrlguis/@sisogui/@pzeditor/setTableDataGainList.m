function setTableDataGainList(Editor,Data,Row)
%setTableData  Method to update the block parameters based on the input
%from java GUI. 

%   Author(s): R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/04/30 00:36:57 $

import java.lang.* java.awt.*;

%% if empty, return
GainList = Editor.GainList;
if isempty(GainList)
    return
end

%% filter out tunable gains only
len = length(GainList);
tunableList = false(len,1);
for ct=1:len
    % Unlike Gain blocks, Tunable field of the 'PID 1dof' block has multiple entries
    tunableList(ct) = any(strcmp({GainList(ct).Parameters.Tunable},'on'));
end
indvalid = tunableList;

%% filter out double value parameters only
for ct = numel(GainList):-1:1
    if ~strcmp('double',class(GainList(ct).Gain))
        indvalid(ct) = false;
    end
end
indvalid = find(indvalid);

%% update all the gains
try
    EventMgr = Editor.Parent.EventManager;
    T = ctrluis.transaction(Editor.LoopData,'Name','Edit Parameter Value',...
        'OperationStore','on','InverseOperationStore','on');
    newValue = eval(Data(Row,2));    
    Editor.GainList(indvalid(Row)).setZPKGain(newValue);        
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
