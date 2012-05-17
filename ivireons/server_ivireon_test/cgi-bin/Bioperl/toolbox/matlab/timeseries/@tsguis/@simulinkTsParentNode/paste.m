function paste(this,manager)
%% Paste menu callback

%   Copyright 2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $ $Date: 2005/06/27 23:00:10 $

Clip = manager.Root.Tsviewer.Clipboard;

if isa(Clip,'tsguis.simulinkTsNode')
    %% Copy the timeseries in the cliboard and give it a name which is unquie
    %% in the treeview
    newts = Clip.Timeseries.copy;
    newname = sprintf('Copy_of_%s', Clip.Timeseries.Name);
    k = 2;
    G = this.getChildren;
    for n = 1:length(G)
        if isa(G(n),'tsguis.simulinkTsNode') && strcmp(newname,G(n).Label)
            newname = sprintf('Copy_%d_of_%s',k,Clip.Timeseries.Name);
            k = k+1;
        end
    end
    newts.Name = newname;
    newNode = createTstoolNode(newts, this);
    this.addNode(newNode);
elseif isa(Clip,'tsguis.simulinkTsArrayNode')
    %% Copy the model in the cliboard and give it a label which is unquie
    %% in the treeview
    newmod = Clip.SimModelhandle.copy;
    newname = sprintf('Copy_of_%s', Clip.SimModelhandle.Name);
    k = 2;
    G = this.getChildren;
    for n = 1:length(G)
        if strcmp(class(G(n)),class(newmod)) && strcmp(newname,G(n).Label)
            newname = sprintf('Copy_%d_of_%s',k,...
                Clip.SimModelhandle.Name);
            k = k+1;
        end
    end

    %newtsc.Name = newname;
    %% Create new model node
    newNode = createTstoolNode(newmod, this, newname);
    this.addNode(newNode);
    %this.createChild(newtsc,newname);
end
