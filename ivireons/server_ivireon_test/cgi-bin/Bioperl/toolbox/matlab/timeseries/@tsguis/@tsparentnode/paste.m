function paste(this,manager)

% Copyright 2004-2005 The MathWorks, Inc.

%% Paste menu callback


if isa(manager.Root.Tsviewer.Clipboard,'tsguis.tsnode')

    %% Copy the timeseries in the cliboard and give it a name which is unquie
    %% in the treeview
    newts = manager.Root.Tsviewer.Clipboard.Timeseries.copy;
    newname = sprintf('Copy_of_%s', manager.Root.Tsviewer.Clipboard.Timeseries.Name);
    k = 2;
    G = this.getChildren;
    for n = 1:length(G)
        if isa(G(n),'tsguis.tsnode') && strcmp(newname,G(n).Label)
            newname = sprintf('Copy_%d_of_%s',k,...
                manager.Root.Tsviewer.Clipboard.Timeseries.Name);
            k = k+1;
        end
    end
    newts.Name = newname;
    %% Create new timeseries node
    this.createChild(newts,newname);
elseif isa(manager.Root.Tsviewer.Clipboard,'tsguis.tscollectionNode')
    %% Copy the tscollection in the cliboard and give it a name which is unquie
    %% in the treeview
    newtsc = manager.Root.Tsviewer.Clipboard.Tscollection.copy;
    newname = sprintf('Copy_of_%s', manager.Root.Tsviewer.Clipboard.Tscollection.Name);
    k = 2;
    G = this.getChildren;
    for n = 1:length(G)
        if isa(G(n),'tsguis.tscollectionNode') && strcmp(newname,G(n).Label)
            newname = sprintf('Copy_%d_of_%s',k,...
                manager.Root.Tsviewer.Clipboard.Tscollection.Name);
            k = k+1;
        end
    end

    newtsc.Name = newname;
    %% Create new timeseries node
    this.createChild(newtsc,newname);
end