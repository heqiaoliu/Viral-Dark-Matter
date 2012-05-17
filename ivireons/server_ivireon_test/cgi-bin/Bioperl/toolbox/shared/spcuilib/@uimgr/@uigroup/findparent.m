function [hChild,idx] = findparent(hGroup,varargin)
%FINDPARENT Return handle to parent of named child.
%   [hChild,idx]=FINDPARENT(hGroup,Name) returns the handle
%   to the parent of the named child, and its index.
%   In effect, FINDPARENT is identical to FINDCHILD except
%   that it removes the last name specified in the hierarchical
%   NAME

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/27 23:30:40 $

% Allow single cellstr, or a varargin list
% Normalize by creating a single cellstr:
if (numel(varargin)==1) && iscellstr(varargin{1})
    % user passed in cell-array of strings
    ChildName = varargin{1};
else
    % multi-args: keep as cell-array of strings
    ChildName = varargin;
end

% Remove last name specified, to get to parent,
% and pass request to findchild:
ParentName = ChildName(1:end-1);
if isempty(ParentName)
    hChild=hGroup;
    idx=0;  % it is the top-level, not a child
else
    [hChild,idx] = findchild(hGroup,ParentName);
end

% [EOF]
