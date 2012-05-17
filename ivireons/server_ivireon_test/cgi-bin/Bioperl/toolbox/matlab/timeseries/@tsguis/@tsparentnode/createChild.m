function childNodes = createChild(h,varargin)
% creates the children nodes.

%   Copyright 2005-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.13 $ $Date: 2009/10/29 15:23:24 $

childNodes = [];
if nargin==1
    % Add from import dialog
    tmp = tsguis.tsImportdlg('Title','Import Time Series/Collection from MATLAB Workspace',...
           'HelpFile','d_import_fr_workspace',...
           'TypesAllowed',{'timeseries','tscollection'});
    tmp.open;    
    if isempty(tmp.OutputValue)     
        return
    else
        names = fieldnames(tmp.OutputValue);
        for i=1:length(names)
            ts = tmp.OutputValue.(names{i});
            
            % Empty tscollections cannot be imported
            if isa(ts,'tsdata.tscollection') && isempty(ts.Time)
                msg = sprintf('The tscollection with name %s has a null time vector and cannot be imported',...
                    ts.Name);
                errordlg(msg,'Time Series Tools','modal');
                continue
            end
            
            if ishandle(ts) %make a deep copy of UDD objects to insulate it from workspace
                ts = ts.copy;
            end

            [isdup,bad_name] = utChkforSlashInName(ts);
            if isdup
                msg = sprintf('Slashes (''/'') are not allowed in the imported object names. Please remove slashes from ''%s'' before importing.',bad_name);
                errordlg(msg,'Time Series Tools','modal');
                continue
            end
            children = createTstoolNode(ts,h);
            if ~isempty(children)
                childNodes = [childNodes(:); h.addNode(children)];
            else
                return
            end
        end
    end
else % The timeseries or tscollection has been supplied as an argument
    newObj = varargin{1};
    if iscell(newObj)
        for k=1:length(newObj)
            if nargin>=3
                [msg,newObj{k}] = localCheckObj(newObj{k},varargin{2});
            else
                [msg,newObj{k}] = localCheckObj(newObj{k});
            end
            if ~isempty(msg)
                childNodes = [];
                return
            end
            try
                children(k) = createTstoolNode(newObj{k},h); %#ok<AGROW>
            catch %#ok<CTCH>
                error('tsparentnode:createChild:invmethod',...
                    'Please supply a valid createTstoolNode method for %s',class(newObj));
            end
        end
    else       
        if nargin>=3
            [msg,newObj] = localCheckObj(newObj,varargin{2});
        else
            [msg,newObj] = localCheckObj(newObj);
        end
        if ~isempty(msg)
            return
        end
        children = createTstoolNode(newObj,h); 
    end
    if isempty(children)
        childNodes = [];
        return
    end
    for k=1:length(children)
        childNodes = [childNodes(:); h.addNode(children(k))];
    end
end

%% Expand and select the newly added node
% The setSelectedNode method will ultimately be executed on the awt thread.
% Consequently if >1 nodes are being added its callback (getDialogInterface)
% may fire after the 2nd or higher node has been added. This
% would result in two or more node panels being visible at once.
if ~isempty(childNodes)
    h.getRoot.Tsviewer.TreeManager.reset
    h.getRoot.Tsviewer.TreeManager.Tree.expand(h.getTreeNodeInterface);
    drawnow % Make sure all events are processed before node selection callback fires
    h.getRoot.Tsviewer.TreeManager.Tree.setSelectedNode(childNodes(1).getTreeNodeInterface);
    drawnow
    h.getRoot.Tsviewer.TreeManager.Tree.repaint
end


function [msg,newObj] = localCheckObj(newObj,varargin)

msg = '';

% Empty tscollections cannot be imported
if isa(newObj,'tscollection') && isempty(newObj.Time)
     msg = sprintf('The tscollection with name %s has a null time vector and cannot be imported',...
                   newObj.Name);
     uiwait(errordlg(msg,'Time Series Tools','modal'));
     return
end
            
if ishandle(newObj) %make a deep copy of UDD objects to insulate it from workspace
     newObj = newObj.copy;
end
 
% Check for object with empty name or named 'unnamed'
if isempty(newObj.name)
    newObj.name = 'unnamed';
end
if strcmp(newObj.name,'unnamed') && nargin>=2 && ~isempty(varargin{1})
    newObj.name = varargin{1};
end
 
[isdup,bad_name] = utChkforSlashInName(newObj);
if isdup
    msg = sprintf('Slashes (''/'') are not allowed in the imported object names. Please remove slashes from ''%s'' before importing %s.',bad_name,newObj.Name);
    errordlg(msg,'Time Series Tools','modal');
    return
end 

% Check that the timeseries does not have too many columns
if isa(newObj,'tsdata.timeseries') && size(newObj.Data,2)>10000
    msg = sprintf('Timeseries with >10000 columns cannot be used in tstool. Try transposing the data or restricting the number of column before importing.');
    errordlg(msg,'Time Series Tools','modal');
    return
end 