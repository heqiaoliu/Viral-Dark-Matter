function child = createChild(h,varargin)
%Create the children nodes.
% The children nodes can be one or more of the following (6) types:
% Simulink.Timeseries, Simulink.TsArray, Simulink.SubsysDataLogs,
% Simulink.StateflowDataLogs, Simulink.ScopeDataLogs,
% Simulink.ModeDataLogs.

%   Copyright 2004-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $ $Date: 2008/07/18 18:44:14 $

child = [];
if nargin==1
    tmp = tsguis.tsImportdlg('Title','Import Simulink Logged Data from MATLAB Workspace',...
           'HelpFile','d_import_simulink',...
           'typesallowed',{'Simulink.ModelDataLogs','Simulink.SubsysDataLogs',...
               'Simulink.Timeseries','Simulink.TsArray','Simulink.ScopeDataLogs',...
               'Simulink.StateflowDataLogs'});
    tmp.open;
    if isempty(tmp.OutputValue)
        return
    else
        names = fieldnames(tmp.OutputValue);
        for i = 1:length(names)
            simu_object = tmp.OutputValue.(names{i});
            %make a deep copy of UDD objects to insulate it from workspace
            % do this only for timeseries and tsarray
            if ishandle(simu_object) && ...
                    ( isa(simu_object,'Simulink.Timeseries') ||...
                     isa(simu_object,'Simulink.TsArray') )
                simu_object = simu_object.copy;
            end
            [isdup,bad_name] = utChkforSlashInName(simu_object);
            if isdup
                msg = sprintf('Slashes (''/'') are not allowed in the imported object names. Please remove slashes from ''%s'' before importing %s signals.',bad_name,simu_object.Name);
                errordlg(msg,'Time Series Tools','modal');
                continue
            end
            child = createTstoolNode(simu_object,h,names{i});
            if ~isempty(child)
                child = h.addNode(child);
            end
        end
    end
else % A Simulink child has been supplied as an argument
    newObj = varargin{1};
    if nargin<=2
        Varname = newObj.Name;
    else
        Varname = varargin{2};
    end
    %make a deep copy of UDD objects to insulate it from workspace
    % do this only for timeseries and tsarray, since ModelDataLogs
    % can't be copied right now.
    if ishandle(newObj) && ...
            ( isa(newObj,'Simulink.Timeseries') ||...
            isa(newObj,'Simulink.TsArray') )
        newObj = newObj.copy;
    end
    [isdup,bad_name] = utChkforSlashInName(newObj);
    if isdup
        msg = sprintf('Slashes (''/'') are not allowed in the imported object names. Please remove slashes from ''%s'' before importing %s.',bad_name,newObj.Name);
        errordlg(msg,'Time Series Tools','modal');
        return
    end
    try
        if nargin>3 && strcmp(class(newObj),'Simulink.ModelDataLogs')
            %replace option has been exercised
            name2look4 = [Varname,' (',newObj.Name,')'];
            ExistingNode = find(h.getChildren,'label',name2look4);
            if ~isempty(ExistingNode)
                w1 = newObj.whos('all');
                w2 = ExistingNode.SimModelhandle.whos('all');

                if isequal(w1,w2)
                    ExistingNode.SimModelhandle = newObj;
                    %refresh the data; do not regenerate the nodes
                    recorder = tsguis.recorder;
                    %create one transaction for the whole change
                    T = tsguis.transaction;
                    localReplaceData(ExistingNode,newObj,T);

                    if strcmp(recorder.Recording,'on')
                        T.addbuffer(sprintf('%% Simulink logged data for ''%s'' was modified by a simulation.',newObj.Name));
                    end

                    % Add the timeseries to the transaction object
                    T.commit;
                    recorder.pushundo(T);
                    return
                else
                    % Replace the whole node
                    localRemovalCleanup(h,ExistingNode);
                    child = createTstoolNode(newObj,h,Varname);
                end
            else %ExistingNode is empty
                child = createTstoolNode(newObj,h,Varname); %method of the data object "newObj"
            end
        else %not a replace option on ModelDataLogs..
            child = createTstoolNode(newObj,h,Varname); %method of the data object "newObj"
        end

        if ~isempty(child)
            child = h.addNode(child);
        end
    catch me
        rethrow(me)
    end
end
if ~isempty(child)
    h.getRoot.Tsviewer.TreeManager.reset
    if child.AllowsChildren && ~isempty(child.getChildren)
        %h.getRoot.Tsviewer.TreeManager.Tree.expand(h.getTreeNodeInterface);
        h.getRoot.Tsviewer.TreeManager.Tree.expand(child.getTreeNodeInterface);
        drawnow % Make sure all events are processed before node selection callback fires
        h.getRoot.Tsviewer.TreeManager.Tree.setSelectedNode(child.down.getTreeNodeInterface);
    else
        h.getRoot.Tsviewer.TreeManager.Tree.expand(h.getTreeNodeInterface);
        drawnow % Make sure all events are processed before node selection callback fires
        h.getRoot.Tsviewer.TreeManager.Tree.setSelectedNode(child.getTreeNodeInterface);
    end

    drawnow % Force the node to show seelcted
    h.getRoot.Tsviewer.TreeManager.Tree.repaint
end
%--------------------------------------------------------------------------
function localRemovalCleanup(h,node)
% Remove the node, clear the transactions and update cache

% Get a list of all the node's Timeseries children
Tslist = tstoolUnpack(node.SimModelhandle);

% Resfresh the transactions stack
utMayBeFlushTransactions(h,Tslist);

% Now disconnect and remove the node from tree
h.removeNode(node);

% Finally, update the cache and send tsstrcuturechange event
ed = tsexplorer.tstreeevent(h.getRoot,'remove',node);
h.getRoot.fireTsStructureChangeEvent(ed,'all');

%--------------------------------------------------------------------------
function localReplaceData(node,data,T)
%refresh the data associatecd with node with the contents of data.
%node: handle to the modelDataLogsNode.
%data: handle to the "new" ModeDataLogs data object.

C = node.getChildren;
for k = 1:length(C)
    switch class(C(k))
        case 'tsguis.simulinkTsNode'
            T.ObjectsCell = {T.ObjectsCell{:},C(k).Timeseries};
            L = C(k).Label;
            newdata = data.(L);
            if ~ishandle(newdata)
                errordlg('The Model Data Logs objects in the workspace is corrupted. Simulate the model to refresh the data.',...
                    'Time Series Tools','modal')
                return
            end

            % Refresh timeseries data
            En = C(k).TsListener.Enabled;
            C(k).TsListener.Enabled = 'off'; %do not listen to init sending 'datachange' event
            
            % Check for empty names (tsrray children could have no names)
            if isempty(newdata.Name)
                newdata.Name = L;
            end

            status = prepareTsDataforImport(newdata);
            if ~status
                C(k).TsListener.Enabled = En; %#ok<NASGU>
                return
            end

            % Now replace data in the object
            if ~isempty(C(k).Timeseries.TimeInfo.StartDate)
                C(k).Timeseries.TimeInfo.StartDate = '';
            end
            C(k).Timeseries.init(newdata.data,newdata.Time);
            C(k).Timeseries.Events = newdata.Events;
            C(k).TsListener.Enabled = En;   
            C(k).Timeseries.fireDataChangeEvent;
        otherwise
            % Browse children until all terminal (timeseries) nodes are found
            % childdata = eval(['data.',['(''',C(k).SimModelhandle.Name,''')']]);
            childdata =  data.(C(k).SimModelhandle.Name);
            localReplaceData(C(k),childdata,T);
    end
end

