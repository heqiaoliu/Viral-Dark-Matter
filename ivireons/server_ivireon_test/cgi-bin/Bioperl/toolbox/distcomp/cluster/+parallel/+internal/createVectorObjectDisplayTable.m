function table = createVectorObjectDisplayTable(objects, tableDesc, title, addIndex)
; %#ok Undocumented
%createVectorObjectDisplayTable
% tableDesc  an array of column description structs with fields:
%              function: cell array containing the functions to call on
%                        each object in order to get the row's contentt
%                        (generated in computeTableContents)
%              title:    string containing the column title
%              width:    minimal column width (in characters)
%              adjust:   column may adjust width (grow), true or false
% title      string that will be printed and underlined
% addIndex   if true the first column is an index (default: true)

%   Copyright 2010 The MathWorks, Inc.

%% Compute the tables content
tableDesc = computeTableContents(objects, tableDesc);
if nargin < 4 || addIndex
    tableDesc = addIndexColumn(tableDesc);
end
%% Table math
% This block computes the optimal width of all the columns depending
% on the screen width, their contents and whether they can be adjusted.

% Minimal width of all cols with separator.
requiredWidth = sum([tableDesc.width]) + (numel(tableDesc)-1)*numel(iColSep());
% Table should fit into command window.
tableWidth = distcomp.dctCmdWindowSize() - 1 - numel(iLinePrefix());
% The amount of room for expansion.
available = max(0, tableWidth - requiredWidth - 1);
% Maximum column width (contents dependent).
maxColWidth = zeros(1, numel(tableDesc));
for i = 1:numel(tableDesc)
    maxColWidth(i) = max(cellfun(@length, tableDesc(i).content));
end
% Each column would like to expand by this (if there's enough space)
% and if allowed to adjust.
expand = max(maxColWidth - [tableDesc.width], 0).*[tableDesc.adjust];
% The fraction of desired space that can be allowed per column.
fraction = min(1, available / sum(expand));
% The additional width for each column (no column gets wider than needed).
adjustBy = (min(expand * fraction, maxColWidth));

%% Table header
underline = repmat(iTitleUnderline(), 1, numel(title));
table = sprintf('%s%s\n%s%s\n\n', iTitlePrefix(), title, iTitlePrefix(), ...
                underline(1:numel(title)));
row = '';
for i = 1:numel(tableDesc)
    tableDesc(i).width = int8(tableDesc(i).width + adjustBy(i));
    row = iAddFieldToRow(row, tableDesc(i).title, ...
                         tableDesc(i).width);
end
table = iAddRowToTable(table, row);
underline = repmat(iHeadUnderline(), 1, numel(row));
table = iAddRowToTable(table, underline(1:numel(row)));

%% Create rows from table contents
for i = 1:numel(tableDesc(1).content)
    row = '';
    for j = 1:numel(tableDesc)
        row = iAddFieldToRow(row, tableDesc(j).content{i}, tableDesc(j).width);
    end
    table = iAddRowToTable(table, row);
end
end

function table = iAddRowToTable(table, row)
table = sprintf('%s%s%s\n', table, iLinePrefix(), row);
end

function row = iAddFieldToRow(row, field, width)
if isempty(row)
    formatStr = ['%s%' num2str(width) 's'];
else
    formatStr = ['%s' iColSep() '%' num2str(width) 's'];
end
row = sprintf(formatStr, row, iTruncate(field, width));
end

function out = iTruncate(in, width)
% Truncate input string if it is longer than width.
%  If truncated, replace last character with '...'.
if numel(in) > width
    out = [in(1:width-3) '...'];
else
    out = in;
end
end

%% Create table contents
function desc = computeTableContents(obj, desc)
for i = 1:numel(obj)
    try
        for j = 1:numel(desc)
            desc(j).content{i} = char(desc(j).function(obj(i)));
        end
    catch err %#ok<NASGU>
        desc(1).content{i} = 'N/A';
    end
end
end

%% Add index column
function desc = addIndexColumn(desc)
num = numel(desc(1).content);
index.content  = arrayfun(@num2str, 1:num, 'UniformOutput', false);
index.title    = '#';
index.width    = 2;
index.adjust   = true;
index.function = [];
desc = [index desc];
end

%% Some table formatting constants
function linePrefix = iLinePrefix()
linePrefix = ' ';
end

function colSep = iColSep()
colSep = '  ';
end

function char = iHeadUnderline()
char = '-';
end

function titlePrefix = iTitlePrefix()
titlePrefix = '    ';
end

function str = iTitleUnderline()
str = '=';
end

