function selectSignal(this,dialog)
%

% SELECTSIGNAL - Updates tool component when a tree element is selected.

%  Author(s): Erman Korkut
%  Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/22 04:26:16 $

% Get the selected IDs
selections = dialog.getWidgetValue('selsigview_signalsTree');
treedata = this.TCPeer.getDDGTreeData;
selectedids = LocalFindSelectedIDs(selections,treedata.StringPaths,this.TCPeer.getOptions);
% Apply selections - we avoid a full update here as it redraws the tree and makes
% multi-selection not work.
this.TCPeer.applyTreeSelections(selectedids);
% Notify other widgets in the dialog
evdata = sigselector.DDGSelectEvent(this,'TreeSelectionEvent',dialog,this.TCPeer);
send(this,'TreeSelectionEvent',evdata);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalFindSelectedIDs
%  Find the IDs for the selected nodes by comparing against full flat list
%  of string paths that are in the same order as the ID numbers.
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ids = LocalFindSelectedIDs(selections,userdata,opts)
if opts.TreeMultipleSelection
    % Multiple selections possible
    len = numel(selections);
    ids = zeros(len,1);
    for ct = 1:len
        ids(ct) = find(strcmp(selections{ct},userdata));
    end
else
    % Find the single selection
    ids = find(strcmp(selections,userdata));
end

    



