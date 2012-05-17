function deletepz(Editor)
%DELETEPZ  Deletes pole/zero group

%   Author(s): C. Buhr
%   Revised by R. Chen
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2008/05/31 23:16:13 $

PZGroups = Editor.CompList(Editor.idxC).PZGroup(Editor.idxPZ);

% Start transaction
EventMgr = Editor.Parent.EventManager;
T = ctrluis.transaction(Editor.LoopData,'Name',sprintf('Delete Poles/Zeros'),...
    'OperationStore','on','InverseOperationStore','on');

% Delete the PZGroup associated with compensator as idxC and rows as idxPZ
% successful action on the SISOTOOL side will be recorded
KeepTransaction = false(length(PZGroups),1);
for ct=1:length(PZGroups)
    try
        Editor.CompList(Editor.idxC).deletePZ(PZGroups(ct));
        KeepTransaction(ct) = true;
    catch ME
        errstr = ltipack.utStripErrorHeader(ME.message);
        awtinvoke('com.mathworks.mwswing.MJOptionPane', ...
            'showMessageDialog(Ljava/awt/Component;Ljava/lang/Object;Ljava/lang/String;I)', ...
            slctrlexplorer, errstr, xlate('SISOTOOL Pole/Zero Editor'), com.mathworks.mwswing.MJOptionPane.ERROR_MESSAGE);
        break;
    end
end

if any(KeepTransaction)
    % Register transaction
    EventMgr.record(T);
    % Notify status and history listeners
    Status = sprintf('Deleted Poles/Zeros.');
    EventMgr.newstatus(Status);
    EventMgr.recordtxt('history',Status);
else 
    T.Transaction.commit; % commit transaction before deleting wrapper
    delete(T);
end

Editor.idxPZ = [];

% broadcast event to all
try
    % broadcasting loopdata change event
    Editor.exportdata;
catch ME
    errstr = ltipack.utStripErrorHeader(ME.message);
    awtinvoke('com.mathworks.mwswing.MJOptionPane', ...
            'showMessageDialog(Ljava/awt/Component;Ljava/lang/Object;Ljava/lang/String;I)', ...
            slctrlexplorer, errstr, xlate('SISOTOOL Pole/Zero Editor'), com.mathworks.mwswing.MJOptionPane.ERROR_MESSAGE);
end
