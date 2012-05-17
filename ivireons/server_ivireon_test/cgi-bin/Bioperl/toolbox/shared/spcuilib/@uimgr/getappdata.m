function [y,foundData] = getappdata(hHG,name)
%GETAPPDATA Get value of application-defined data from a UIMgr node.
%   VALUE = GETAPPDATA(H, NAME) gets the value of the application-
%   defined data with name specified by NAME in UIMgr object H, and
%   ascending the UIMgr tree.  If the application-defined data does
%   not exist, an empty matrix will be returned in VALUE.
%
%   If NAME is a cell-array of strings, VALUE is a cell-array of values.
%
%   VALUE = GETAPPDATA(HG, NAME) gets the value of the application-
%   defined from the UIMgr node corresponding to the HG graphics primitive
%   handle HG, then ascending up the UIMgr tree.  If the HG handle
%   was not rendered by a UIMgr node, an error will result.
%
%   [VALUE,FOUND] = GETAPPDATA(...) returns TRUE for FOUND
%   if the application-defined data exists.
%
%   Note that application is set on individual nodes using the
%   method SETAPPDATA on the UIMgr node itself.

% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2008/02/02 13:12:04 $

if isa(hHG,'uimgr.uiitem')
    hRootNode = hHG;  % UIMgr node passed in
else
    % Get UIMgr node corresponding to the HG primitive passed in
    try
        hRootNode = hHG.uimgr;
    catch e %#ok
        error('uimgr:getappdata:InvalidHandle', ...
            'Handle H is not associated with a UIMgr tree node.');
    end
end
if ~ischar(name) && ~iscellstr(name)
    error('uimgr:getappdata:InvalidName', ...
        'Name must be a string or a cell-array of strings.');
end
% Force name into a cell array
cellResult = iscell(name);
if ~cellResult
    name = {name};
end

% Ascend to find an icon cache associated with a parent uimgr node
% Keep ascending until the named icons are found
N = numel(name);
y = cell(1,N);
foundData = false(1,N);
for i=1:N    % must be >= 1 entries at this point
    hNode = hRootNode;
    while ~foundData(i) && ~isempty(hNode)
        [y{i},foundData(i)] = getappdata(hNode,name{i});
        hNode = hNode.up;
    end
end

% Return simple array (and not a cell) if name arg was not
% passed in as a cell-array itself:
if ~cellResult
    y = y{1};
end

% [EOF]
