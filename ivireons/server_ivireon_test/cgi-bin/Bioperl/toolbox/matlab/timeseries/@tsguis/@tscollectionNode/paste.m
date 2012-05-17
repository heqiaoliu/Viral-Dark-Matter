function paste(this,manager)

% Copyright 2005 The MathWorks, Inc.

%% Paste menu callback


if isa(manager.Root.Tsviewer.Clipboard,'tsguis.tsnode')

    %% Copy the timeseries in the cliboard and give it a name which is unquie
    %% in the treeview
    newts = manager.Root.Tsviewer.Clipboard.Timeseries.copy;
    if  ~tsIsSameTime(newts.Time, this.Tscollection.Time)
        return;
    end
    newname = sprintf('Copy_of_%s', manager.Root.Tsviewer.Clipboard.Timeseries.Name);
    k = 2;
    while any(strcmp(newname,get(this.getChildren,{'Label'})))
        newname = sprintf('Copy_%d_of_%s',k,...
            manager.Root.Tsviewer.Clipboard.Timeseries.Name);
        k = k+1;
    end
    newts.Name = newname;

    %% Create new timeseries node by updating the tscollection object ..
    % (The following method adds time series member to the tscollection and also
    % records the transaction)
    this.addTsCallback(newts);
elseif isa(manager.Root.Tsviewer.Clipboard,'tsguis.tscollectionNode')
    this.getParentNode.paste(manager);
end