function node = createTstoolNode(ts,h)
%CREATETSTOOLNODE Creates a node for the time series object in the tstool
%tree. 
%
%   CREATETSTOOLNODE(TS,H) where H is the parent node object. Information
%   from h is required to check against existing node with same name.

%   Author(s): Rajiv Singh
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $ $Date: 2006/06/27 23:08:16 $

node = [];

status = prepareTsDataforImport(ts);
if ~status
    return
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Time series object must have unique name in tstool
% check duplication
if localDoesNameExist(h,ts.tsValue.Name)
    % Duplicated, check if same handle handle
    % different but same name, ask if a name change is desired
    tmpname = ts.tsValue.Name;
    Namestr = sprintf('Time Series object  ''%s''  is already defined.\n\nPlease give a different name for the new object to be imported :\n', ...
            tmpname);
    while true
        answer = inputdlg(Namestr,xlate('Enter Unique Name'));
        % comparing the given new name with all the nodes in tstool
        %return if Cancel button was pressed
        if isempty(answer)
            return;
        end
        tmpname = strtrim(cell2mat(answer));
        if isempty(tmpname)
            Namestr = sprintf('Empty names are not allowed. \n\nPlease give a different name for the new object to be imported :');
        else
            tmpname = strtrim(cell2mat(answer));
            %node = h.getChildren('Label',tmpname);
            if localDoesNameExist(h,tmpname)
                Namestr = sprintf('Time Series object  ''%s''  is already defined.\n\nPlease give a different name for the new object to be imported :\n',tmpname);
                continue;
            else
                ts.tsValue.name = tmpname;
                break;
            end %if ~isempty(node)
        end %if isempty(answer)
    end %while
end %if ~isempty(node) ..
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Create a @tsnode
node = tsguis.tsnode(ts);

% attach a listener to the leaf node, which would listen to the datachange
% event of the timeseries data object
node.Tslistener = handle.listener(node.Timeseries,'datachange',{@(e,d) node.updatePanel(d)});


%Attach a listener to the data object Name change property
node.DataNameChangeListener = handle.listener(node.Timeseries,...
    node.Timeseries.findprop('Name'),'PropertyPostSet',{@localUpdateNodeName, node});

%--------------------------------------------------------------------------
function localUpdateNodeName(es,ed,node)

newName = node.Timeseries.Name; 
node.updateNodeNameCallback(newName);

%--------------------------------------------------------------------------
function Flag = localDoesNameExist(h,name)

nodes = h.getChildren('Label',name);
Flag = false;
if ~isempty(nodes)
    for k = 1:length(nodes)
        if strcmp(class(nodes(k)),'tsguis.tsnode')
            Flag = true;
            break;
        end
    end
end