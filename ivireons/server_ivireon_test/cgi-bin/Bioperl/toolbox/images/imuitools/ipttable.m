function varargout = ipttable(varargin)
%IPTTABLE Display data in a two-column table.
%   IPTTABLE produces a warning and will be removed in a future version.
%   Use UITABLE instead.  
%
%   HP = IPTTABLE(HPARENT,DATA) displays the information in DATA in a
%   two-column table. IPTTABLE creates the table in a uipanel object and
%   returns HP, a handle to this object. HPARENT specifies the figure or
%   uipanel object that will contain the table uipanel.
%   
%   DATA can be a structure or a cell array.
%
%   If data is a structure, IPTTABLE displays the structure fieldnames
%   in the first column of the table and the corresponding values in 
%   the second column of the table. The columns have the headings
%   "Fieldname" and "Value", respectively. 
%
%   Note: IPTTABLE displays only the first level of the structure. 
%
%   If data is a cell array, the cell array must be N-by-2. IPTTABLE 
%   displays the first element in each row of the cell array in the 
%   the first column of the table and the second element in each row
%   of the cell array in the second column of the table. The columns
%   have the headings "Attribute" and "Value", respectively.
%
%   Positioning
%   -----------
%   IPTTABLE positions the uipanel object it creates in the lower-left
%   corner of HPARENT. IPTTABLE sizes the uipanel to fit the amount of
%   information in the table, up to the maximum size of HPARENT. If 
%   the table doesn't fit, IPTTABLE adds scroll bars to the table.
%
%   Depending on the amount of information to display, IPTTABLE can 
%   appear to take over the entire figure. By default, HPANEL has
%   'Units' set to 'normalized' and 'Position' set
%   to [0 0 1 1]. If you want to see the other children of HPARENT, you
%   must manually set the 'Position' property of HPANEL.
%
%   Examples
%   --------
%
%       hfig = figure;
%       structure = imfinfo('snowflakes.png');
%       hp = ipttable(hfig,structure);
%       set(hp,'BorderType','etchedin');
%
%       h = imshow('snowflakes.png');
%       hfig = figure;
%       cellarray = imattributes(h);
%       hp = ipttable(hfig,cellarray);
%       set(hp,'BorderType','beveledin');
%
%   See also UITABLE.

%   [HP, HUIT] = IPTTABLE(...) returns a handle to the uitable, HUIT,
%   contained in HP for testing purposes. HUIT is not accessible in the
%   graphics hierarchy.

%   Copyright 1993-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2008/05/12 21:27:20 $

% the IPTTABLE function is deprecated and will be removed
wid = sprintf('Images:%s:deprecatedFunction',mfilename);
warning(wid,'IPTTABLE will be removed in a future version. Use UITABLE instead.');

[hparent,tableData,columnNames] = parseInputs(varargin{:});

%%
hp = uipanel('Parent', hparent,...
    'Units','pixels',...
    'BorderType','none',...
    'Tag','ipttable',...
    'Visible','off');
%%
[huit,huic] = uitable('v0', 'Data', tableData,...
    'ColumnNames', columnNames);

set(huic,'Parent',hp,...
    'Visible','off');

set(huit,'Editable', 0);  % must set separately b/c uitable not HG

% declare fudge factors so it has scope. these work b/c uitable font size
% cannot be changed.
fudge = 15;

setPositionOfPanel;
setPositionOfTable;

set(hp,'ResizeFcn',@resizeTable);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    function setPositionOfPanel
        sizes = cellfun('prodofsize',tableData);
        maxWidth = max(sum(sizes,2));
        if isempty(maxWidth)
            maxWidth = 10;  %in event of empty tableData.
            % works b/c uitable's font size cannot be changed
        end
        
        maxHeight = get(huit,'NumRows') + 1; %include header row

        if ispc
          fudgeFactor = 18;
        else
          fudgeFactor = 20;
        end
        
        hpPos = get(hp,'Position');
        set(hp,'Position',[hpPos(1) ...
            hpPos(2) ...
            min(maxWidth*fudge,hpPos(3)) ...
            min(maxHeight*fudgeFactor, hpPos(4))]);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    function setPositionOfTable

        oldUnits = get(hp,'Units');
        set(hp,'Units','pixels');
        hpPos = get(hp,'Position');
        
        set(huic,'Position',[1 1 hpPos(3) hpPos(4)]);

        columnOneWidth = floor(hpPos(3)/ 3) + fudge;
        huit.setColumnWidth(0,columnOneWidth);
        columnTwoWidth = hpPos(3) - columnOneWidth - fudge;
        huit.setColumnWidth(1,columnTwoWidth);
        
        set(hp,'Units',oldUnits);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function resizeTable(obj,evt)
        setPositionOfTable;
    end

set(huic,'Visible','on');
set(hp,'Visible','on');
varargout{1} = hp;
varargout{2} = huit;

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hparent,tableData,colNames] = parseInputs(varargin)

iptchecknargin(2,2,nargin,mfilename);

hparent = varargin{1};
iptcheckhandle(hparent,{'figure','uipanel','uicontainer'},mfilename, ...
    'HPARENT',1);

if ~isJavaFigure
  eid = sprintf('Images:%s:needJavaFigure',mfilename);
  msg = sprintf('%s is not available on this platform.',upper(mfilename));
  error(eid,'%s',msg);
end

if isstruct(varargin{2})
    structure = varargin{2}(1); % in case of multi-frame file
    tableData = createTableDataFromStructure(structure);
    colNames = {'Fieldname' 'Value'};

elseif iscell(varargin{2}) && size(varargin{2},2) == 2
    tableData = createTableDataFromCellArray(varargin{2});
    colNames = {'Attribute' 'Value'};

else
    eid = sprintf('Images:%s:invalidInputArgument',mfilename);
    msg = 'The second input argument must be a valid structure or ';
    msg2 = 'N-by-2 cell array.';
    error(eid,'%s%s',msg,msg2);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tableData = createTableDataFromStructure(s)

fieldNames = fieldnames(s);
values = struct2cell(s);

charArray = evalc('disp(s)');
fieldnameAndValue = strread(charArray,'%s','delimiter','\n');
numLines = length(fieldnameAndValue);
dispOfValues = cell(numLines);
for k = 1 : numLines
  idx = find(fieldnameAndValue{k}==':');
  if ~isempty(idx) % to avoid blank lines
    dispOfValues{k} = fieldnameAndValue{k}((idx(1)+2):end);
  end
end

numFields = length(fieldNames);
tableData = cell(numFields,2);

% First column of tableData contain fieldNames. Second column of tableData
% contains the string representation of values. We use the values or
% dispOfValues depending on whether each element of values is a vector of
% characters.
tableData(:,1) = fieldNames;
for idx = 1: numFields
    val = values{idx};
    if ischar(val) && size(val,1) == 1
        tableData{idx,2} = val;
    else
        tableData{idx,2} = dispOfValues{idx};
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tableData = createTableDataFromCellArray(c)

fieldNames = c(:,1);
values = c(:,2);
charArray = evalc('disp(values)');
dispOfValues = strread(charArray,'%s','delimiter','\n');

numFields = length(fieldNames);
tableData = cell(numFields,2);

% First column of tableData contain fieldNames. Second column of tableData
% contains the string representation of values. We use the values or
% dispOfValues depending on whether each element of values is a vector of
% characters.
tableData(:,1) = fieldNames;
for idx = 1: numFields
    val = values{idx};
    if ischar(val) && size(val,1) == 1
        tableData{idx,2} = val;
    else
        val = dispOfValues{idx};
        spaces = isspace(val);  % Remove extra whitespace,e.g, [    8].
        val(spaces)= '';
        tableData{idx,2} = val;
    end
end

end



