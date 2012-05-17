function set(world, varargin)
%SET Change a property of a VRWORLD object.
%   SET(W, PROPNAME, PROPVALUE) changes a property of the
%   virtual world associated with the given VRWORLD object.
%
%   SET(W, PROPNAME, PROPVALUE, PROPNAME, PROPVALUE, ...)
%   changes the given set of properties of the virtual world.
%
%   See VRWORLD/GET for a detailed list of world properties.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2010/03/01 05:31:04 $ $Author: batserve $


% use this overloaded SET only if the first argument is of type VRWORLD
if ~isa(world, 'vrworld')
  builtin('set',world,varargin{:});
  return;
end

% prepare pair of cell array of names and arguments
[propname, propval] = vrpreparesetargs(numel(world), varargin, 'property');

% loop through worlds
for i=1:size(propval, 1)
  wid = world(i).id;

  % loop through property names
  for j=1:size(propval, 2)
    val = propval{i, j};

    switch lower(propname{j})

      case { 'canvases', 'clients', 'figures', 'nodes', 'id' }
        % read-only properties
        error('VR:propreadonly', 'World property ''%s'' is read-only.', propname{j});
        
      case 'comment'
        % comment can be only string
        if ~ischar(val)
          throwAsCaller(MException('VR:invalidinarg', '''Comment'' property argument must be a string.'));
        end  
        if isopen(world(i))
          % get name of root
          rootname = vrsfunc('GetRootNodeName', wid);
          % set its comment
          vrsfunc('SetNodeComment', wid, rootname, val);
        else
          warning('VR:worldnotopen', 'Changing the ''Comment'' property has no effect for closed world.');  
        end

      otherwise
        % it is not a special property, use the common way
        vrsfunc('SetSceneProperty', wid, propname{j}, val);
    end

    % when the description changes, change the titles of all figures
    if strcmpi(propname(j), 'Description')
      set(get(world(i), 'Figures'), 'Name', val);
    end

  end
end
