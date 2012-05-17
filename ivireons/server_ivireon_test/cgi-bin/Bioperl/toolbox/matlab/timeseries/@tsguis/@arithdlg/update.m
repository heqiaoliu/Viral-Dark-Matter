function update(h,varargin)

% Copyright 2004-2008 The MathWorks, Inc.

%% Refresh the list of timeseries  to agree with
%% the time series nodes in the viewer. The optional 2rd arg specifies a
%% a time series name in the list which should be initially selected, the 
%% optional 3rd argument is a tsstructurechange eventData object signaling
%% a node deletion


%% Is a node being deleted?
skipnode = [];
if nargin>=3 && isa(varargin{2},'tsexplorer.tstreeevent') && ...
        strcmp(get(varargin{2},'Action'),'remove')
    skipnode = get(varargin{2},'Node');
end
%% Get tsnamees and paths
v = tsguis.tsviewer;
v.TreeManager.Root.updatePathCache;
[pathNames,tsNames] = v.TreeManager.Root.dir;

%% Keep the original list at the top so as to minimize the affect on
%% the mapping between identifiers and time series
oldTsData = cell(h.Handles.tsTable.getModel.getData);
if size(oldTsData,2)>=3
   oldTsPaths = oldTsData(:,3);
   ind = ismember(pathNames,oldTsPaths);
   I1 = find(ind);
   I2 = find(~ind);
   pathNames = pathNames([I1(:);I2(:)]);
   tsNames = tsNames([I1(:);I2(:)]);
end

tableData =  cell(0,4);
row = 1;
ind = 0;
for k=1:length(tsNames)
    tsnodes = v.TreeManager.Root.search(pathNames{k});
    if length(tsnodes)==1 && ...
            (isempty(skipnode) || ~any(find(skipnode,'-depth',inf)==tsnodes))
        % Make sure aliases do not include time series names or
        % after aliases are substituted into the expession strings 
        % a further invalid substitution may occur.
        aliasName = localCreateAlais(ind);   
        ind = ind+1;
        tableData(row,:) = {aliasName tsNames{k} pathNames{k}, ...
            sprintf('[%s]',num2str(size(tsnodes.Timeseries.Data)))};
        row = row+1;
    end 
end

%% Populate the table
h.Handles.tsTable.getModel.setDataVector(tableData,{xlate('Identifier'),xlate('Name'),xlate('Path'),xlate('Size')},...
    h.Handles.tsTable);

%% Has a particular time series been selected?
ind = [];
if nargin>=2 && ischar(varargin{1})
    ind = find(strcmp(varargin{1},tableData(:,2)));
    if isempty(ind)
        return
    end
    awtinvoke(h.Handles.tsTable,'clearSelection()')
    awtinvoke(h.Handles.tsTable,'setRowSelectionInterval(II)',...
        ind(1)-1,ind(1)-1);
end


function strout = localCreateAlais(k)

%% Convert integer k into a string using the spreadsheet mapping to columns
k = k+26;
len = ceil(log(k+1)/log(26));
strout = repmat(' ',[1 len]);
for ind=len-1:-1:0
    c = floor(k/(26^ind));
    k = k-c*26^ind;
    if ind>0
        strout(len-ind) = char(c-1+double('a'));
    else
        strout(len-ind) = char(c+double('a'));
    end
end
