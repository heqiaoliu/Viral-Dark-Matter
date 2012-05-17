function nodeName = getTstoolNodeName(h,ts,tstoolNodeClassName,varargin)

% Utility function used by @ModelDataLogs,@StateflowDataLogs,@SubsysDataLogs,
% @TsArray & @ScopeDataLogs check that a node can be created for them
% in tstool.

% Object must be unique in tstool; check that no node with same
% SimModelhandle exists in the tree
nodeName = '';
[isUnique,existingNodeName] = h.isUniqueHandle(ts);
if ~isUnique
    errordlg(sprintf('%s object ''%s'' already exists in Time Series Tools, under a node named ''%s''.\nImport aborted.',...
        class(ts), ts.Name, existingNodeName),'Time Series Tools','modal');
    return
end

% Object must have unique name in tstool
if nargin>=4 && ~isempty(varargin{1})
    nodeLabel = [varargin{1},' (',ts.Name,')'];
else
    nodeLabel = ts.Name;
end
if localDoesNameExist(h,nodeLabel,tstoolNodeClassName)
    % Ask if a name change is desired
    tmpname = nodeLabel;
    namestr = sprintf('%s object ''%s'' is already defined.\n\nSpecify a different name for the new object to be imported :\n', ...
        get(classhandle(ts),'Name'),tmpname);
    while true
        answer = inputdlg(namestr,'Enter Unique Name');
        % Comparing the given new name with all the nodes in tstool
        % return if Cancel button was pressed
        if isempty(answer)
            return;
        end
        tmpname = strtrim(cell2mat(answer));
        if isempty(tmpname)
            namestr = sprintf('Empty names are not allowed.\n\nSpecify a different name for the new object to be imported :');
        else
            tmpname = strtrim(cell2mat(answer));
            if localDoesNameExist(h,tmpname,tstoolNodeClassName)
                namestr = sprintf('%s object ''%s'' is already defined.\n\nSpecify a different name for the new object to be imported :\n', ...
                    get(classhandle(ts),'Name'),tmpname);
                continue;
            else
                nodeLabel = tmpname;
                break;
            end
        end
    end 
end 
nodeName = nodeLabel;

function Flag = localDoesNameExist(h,name,className)

nodes = h.getChildren('Label',name);
Flag = true;
for k = 1:length(nodes)
    if strcmp(class(nodes(k)),className)
        return;
    end
end
Flag = false;