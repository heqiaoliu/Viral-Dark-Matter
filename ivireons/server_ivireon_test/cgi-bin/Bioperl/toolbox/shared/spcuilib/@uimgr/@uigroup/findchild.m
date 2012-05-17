function hChild = findchild(hParent,varargin)
%FINDCHILD Return handle to named child in parent.
%   FINDCHILD(H,NAME) returns a handle to the named child of H.
%   NAME must be a string.  If not found, empty is returned.
%   A case-insensitive search is used for specified name.
%
%   FINDCHILD(H,'N1','N2',...) returns a child multiple levels down
%   from a tree of arbitrary depth, identified by the hierarchy of
%   names N1, N2, etc.  This is the most efficient syntax.
%   FINDCHILD(H,{'N1','N2',...}) also may be used.  Note that N1 is
%   the name of a child of H, and is not the name of H itself.
%
%   FINDCHILD(hGroup,'BASE/N1/N2/...') uses a child path string,
%   identified by the inclusion of one or more forward-slashes,
%   to locate a child of arbitrary depth. Note that the child path
%   includes the name of the top-level tree node, unlike the child
%   addresses defined above.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/05/09 23:40:06 $

hChild = [];

% Search child names for a match
N=numel(varargin);
if N==0
    error('uimgr:NameNotSpecified', 'Name must be specified.');
elseif N==1
    % individual string, or a path, or a cell-array specified
    
    % Assume a single cell passed - which itself is assumed to be a cell of
    % strings.  Pop it out of varargin, which is a double-cell now
    NameList = varargin{1};
    if ~iscell(NameList)
        % This would be a relatively unusual case of finding just the
        % top-level child as an address.
        %
        % But, in this case, also check if this is a "path string"
        % which will have one or more forward-slash chars '/' in it.
        % If so, decompose into multiple separate strings.
        % Path strings DO INCLUDE the "top node" in the string,
        % so we remove it for findchild to work properly.
        %
        % Note the "singularity:
        %  A path string with no delimiter is not interpreted as a path.
        %  It is a single-string address.  Thus, if the full path to
        %  a node in the tree is BaseApp/Toolbars, then 'Toolbars' is
        %  a viable address, and 'BaseApp/Toolbars' is its equivalent.
        %
        % If this has no delimiter, it just returns a cell with the string.
        r = textscan(NameList,'%s','delimiter','/');
        NameList = r{1};
        if numel(NameList)>1
            NameList(1) = [];  % remove top-level address from list
        % else
        %    % it was not a path, it was a single-name address
        end
    end
else
    % multiple individual strings presumed
    NameList = varargin;  % multi-args: keep as cell-array of strings
    
    % Could do a quick check that, say, first element is a string
    % but that's not exhaustive and would just waste time
end

for i=1:numel(NameList)
    % char test not absolutely needed, since find() will work properly
    if ~ischar(NameList{i})
       error('uimgr:NameMustBeString','Names must be specified using strings.');
    end
    hChild = hParent.find('-depth',1,'Name',NameList{i});
    % Workaround for "find" method including parent in search list:
    % Problem only occurs if child name matches parent name,
    % which is valid (and unambiguous) for UIMGR trees.
    hChild = hChild(hChild~=hParent);  % logical indexing
    if isempty(hChild)
        break % Failed to find any match
    end
    % found i'th name in list
    hParent = hChild;
end

% [EOF]
