function n = vrnode(world, nodename, nodetype, newtype)
%VRNODE Create a VRNODE handle to an existing or a new node.
%   N = VRNODE(W, NODENAME) creates a new VRNODE handle for an existing
%   named node from a virtual world associated with the VRWORLD handle W.
%
%   N = VRNODE creates an empty VRNODE handle which does not
%   reference any node.
%
%   N = VRNODE([]) creates an empty array of VRNODE handles.
%
%   N = VRNODE(W, NODENAME, NODETYPE) creates a new named node of name
%   NODENAME and type NODETYPE on root of the world W and returns the VRNODE
%   handle to the newly created node.
%
%   N = VRNODE(W, 'USE', OTHERNODE) creates an USE reference to node OTHERNODE
%   on root of the world W and returns the VRNODE handle to the original node.
%
%   N = VRNODE(PARENTNODE, PARENTFIELD, NODENAME, NODETYPE) creates a new
%   named node of name NODENAME and type NODETYPE which is a child of node
%   PARENTNODE and resides in field PARENTFIELD. The VRNODE handle to the newly
%   created node is returned.
%
%   N = VRNODE(PARENTNODE, PARENTFIELD, 'USE', OTHERNODE) creates an USE
%   reference to node OTHERNODE as a child of node PARENTNODE and
%   residing in field PARENTFIELD. The VRNODE handle to the original node
%   is returned.

%   Copyright 1998-2009 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2009/12/28 04:42:04 $ $Author: batserve $


% if no arguments create an empty VRNODE
if nargin==0
  This = struct('World', vrworld, 'Name', '');
  n = class(This, 'vrnode');
  return;
end;

% return VRNODE 0x0 array for VRNODE([]) or for VRNODE(W, [])
if isempty(world) || isempty(nodename)
  This = struct('World', {}, 'Name', {});
  n = class(This, 'vrnode');
  return;
end;

% check WORLD argument - must be a world unless we have 4 arguments when it is a node
if nargin<4
  if ~isa(world, 'vrworld')
    throwAsCaller(MException('VR:invalidinarg', 'WORLD must be of type VRWORLD.'));
  end
  if numel(world)>1
    throwAsCaller(MException('VR:invalidinarg', 'WORLD cannot be an array.'));
  end
  sw = struct(world);
  wid = sw.id;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<3       % create reference to existing nodes
        
% if node names are strings validate them
if ~ischar(nodename) && ~iscellstr(nodename)
  throwAsCaller(MException('VR:invalidinarg', 'NAME must be a string or a cell array of strings.'));
end

% convert a simple string to cell array containing a single string
if ischar(nodename)
  nodename = { nodename };
end

% check if the nodes exist
for i=1:numel(nodename)
  sw = struct(world);
  wid = sw.id;
  if ~vrsfunc('VRT3NodeExists', wid, nodename{i})
    throwAsCaller(MException('VR:nodenotfound', ['Node ''' nodename{i} ''' not found.']));
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif nargin == 3   % create new nodes on root

% validate arguments
try
  [nodename, nodetype] = checknewnode(wid, nodename, nodetype);
catch ME
  throwAsCaller(ME);
end

% create the nodes
for i=1:numel(nodename)
  try
    nodename{i} = vrsfunc('AddNode', wid, '', '', nodename{i}, nodetype{i});
  catch ME
    throwAsCaller(ME);
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else   % nargin == 4  : create new nodes parented by another node

% reshuffle arguments to assign meaningful names
parentnode = world;
parentfield = nodename;
nodename = nodetype;
nodetype = newtype;
world = parentnode.World;

% validate arguments
if ~isa(parentnode, 'vrnode')
  throwAsCaller(MException('VR:invalidinarg', 'PARENTNODE must be of type VRNODE.'));
end
if numel(parentnode)>1
  throwAsCaller(MException('VR:invalidinarg', 'PARENTNODE cannot be an array.'));
end
if ~ischar(parentfield)
  throwAsCaller(MException('VR:invalidinarg', 'PARENTFIELD must be a string.'));
end
wid = getparentid(parentnode);
try
  [nodename, nodetype] = checknewnode(wid, nodename, nodetype);
catch ME
  throwAsCaller(ME);
end

% create the node
for i=1:numel(nodename)
  try
    nodename{i} = vrsfunc('AddNode', wid, parentnode.Name, parentfield, nodename{i}, nodetype{i});
  catch ME
    throwAsCaller(ME);
  end
end

end

% finally create the VRNODE handles to the validated or created nodes
This = struct('World', world, 'Name', nodename);
n = class(This, 'vrnode');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check new node and type validity
function [nodename, nodetype] = checknewnode(wid, nodename, nodetype)

% convert scalar arguments to cell array
if ~iscell(nodename)
  nodename = {nodename};
  nodetype = {nodetype};
end
if numel(nodename)~=numel(nodetype)
  throwAsCaller(MException('VR:invalidinarg', 'NODENAME and NODETYPE must be either scalars or equally sized cell arrays.'));
end

% check arguments validity
for i=1:numel(nodename)
  if strcmp(nodename{i}, 'USE')
    if ~isa(nodetype{i}, 'vrnode')
      throwAsCaller(MException('VR:invalidinarg', 'Argument to USE must be of type VRNODE.'));
    elseif getparentid(nodetype{i}) ~= wid
      throwAsCaller(MException('VR:invalidinarg', 'USEd nodes must belong to the same world.'));
    end
    nodename{i} = nodetype{i}.Name;
    nodetype{i} = true;

  elseif ~ischar(nodename{i}) || ~ischar(nodetype{i})
    throwAsCaller(MException('VR:invalidinarg', 'NODENAME and NODETYPE arguments must be strings or cell array of strings.'));
  end
end
