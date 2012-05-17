function x = nodes(w, fullswitch)
%NODES List VRML nodes in a virtual world.
%   NODES(W) lists all named nodes contained in the world
%   referenced by a VRWORLD handle W.
%
%   NODES(W, '-full') lists both nodes and their fields.
%
%   X = NODES(W) returns a cell array with names of all
%   named nodes contained in the world. The result is the same
%   as from X = GET(W, 'Nodes').

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:11:07 $ $Author: batserve $


% check arguments
if ~isa(w, 'vrworld')
  error('VR:invalidinarg', 'W must be of type VRWORLD.');
end

% check for invalid worlds
if ~all(isvalid(w(:)))
  error('VR:invalidworld', 'Invalid world.');
end

% look for commandline switches
fullswitch = nargin>1 && strcmpi(fullswitch,'-full');
if nargin>1 && ~fullswitch
  error('VR:invalidinarg', 'Unknown command switch.');
end

% output argument is given: work like GET(W, 'Nodes')
if nargout>0
  x = get(w, 'Nodes');

% empty array of worlds: nothing to print
elseif numel(w)==0
  warning('VR:emptyoutput', 'Empty array of worlds. Nothing to print.');
  return

% no output, full listing: work like FIELDS(GET(W, 'Nodes'))
elseif fullswitch

  % listing of more than one world would be impractically long
  if numel(w)>1
    error('VR:invalidinarg', 'W must be a scalar when a full listing is requested.');
  end

  % empty input array: nothing to print
  nodelist = get(w, 'Nodes');
  if isempty(nodelist)
    warning('VR:emptyoutput', 'World may be closed. Nothing to print.');
    return
  end
  fields(nodelist);

% no output, brief listing: work like DISP(GET(W, 'Nodes'))
else

  % vectorized operation
  if numel(w)>1
    for i=1:numel(w)
      fprintf('\n');
      disp(w(i));
      nodes(w(i));
    end
    return
  end

  % world has no visible nodes: nothing to print
  nodelist = get(w, 'Nodes');
  if isempty(nodelist)
    warning('VR:emptyoutput', 'World may be closed. Nothing to print.');
    return
  end
  
  disp(get(w, 'Nodes'));

end
