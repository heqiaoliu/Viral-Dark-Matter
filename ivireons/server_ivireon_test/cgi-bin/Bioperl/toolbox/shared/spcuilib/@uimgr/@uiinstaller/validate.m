function validate(h,dst)
%VALIDATE Confirm installer consistency and target tree compatibility.
%   VALIDATE confirms that UIINSTALLER object information is consistent
%   and compatible with the target application GUI.
%
%   VALIDATE(H) confirms the following:
%    - Plan contains data types for source groups and destination
%    addresses.
%    - Number of addresses specified in H.DSTADDRS matches
%      number of child nodes in H.SRCGROUP (i.e., a 2-D cell matrix).
%
%   VALIDATE(H,DSTGROUP) additionally confirms the following:
%    - DSTGROUP is an instance of uimgr.uigroup
%    - Each address in the Plan is found within DSTGROUP
%    - Source nodes in Plan are compatible with the specified
%      target tree groups within DSTGROUP.
%
%      For example, if a source node is of type UIMGR.UIBUTTON,
%      and the corresponding node in DSTGROUP as described by
%      H.DSTADDR is of type UIMGR.UIMENUGROUP, an error will occur
%      since a menu group cannot contain a child that is a button.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2006/05/09 23:41:05 $

if ~isempty(h)
    checkConsistency(h);
    if nargin>1
        checkCompatibility(h,dst);
    end
end

% ------------------------------------------
function checkConsistency(h)

% Check data types for source nodes and destination addresses
%
% Plan must be a 2-D cell-matrix with 2 columns
% It could be empty, however.
[Nrows,Ncols]=size(h.Plan);
if ~iscell(h.Plan) || (ndims(h.Plan)>2) || (Ncols~=2 && Ncols~=0)
    error('uimgr:uiinstaller:Inconsistent', ...
        'Plan must be a 2-column cell matrix');
end
%
% Plan must contain UIMgr group nodes and string dest addresses
for i=1:Nrows
    node=h.Plan{i,1};
    if ~isa(node,'uimgr.uiitem')
        error('uimgr:uiinstaller:Inconsistent', ...
            'Source nodes (column 1) in Plan must be UIMgr object');
    end
    addr=h.Plan{i,2};
    if ~ischar(addr)
        error('uimgr:uiinstaller:Inconsistent', ...
            'Destination addresses (column 2) in Plan must be strings');
    end
end

% ------------------------------------------
function checkCompatibility(h,dst)

% Check that DST describes a uimgr.uigroup
if ~isa(dst,'uimgr.uigroup')
    error('uimgr:uiinstaller:validate', ...
        'DSTGROUP must be an object of type UIMGR.UIGROUP');
end

numNodes = size(h.Plan,1); % # nodes to install
for i = 1:numNodes
    % Check that dest address is valid
    srcNode = h.Plan{i,1};
    tgtAddr = h.Plan{i,2};
    thisParent = findchild(dst,tgtAddr);
    if isempty(thisParent)
        error('uimgr:uiinstaller:DestAddrNotFound', ...
            'Target address %d (%s) not found in target application.', ...
            i, tgtAddr);
    end
    
    % Check that dest group is compatible with source item/group
    if ~compatibleParent(srcNode, class(thisParent))
        error('uimgr:uiinstaller:IncompatibleSource', ...
            ['Source node %d (%s) is incompatible\n', ...
             'with target parent (%s)'], ...
             i, getPath(srcNode), getPath(thisParent));
    end
end

% [EOF]
