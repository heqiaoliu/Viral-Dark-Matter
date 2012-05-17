function set(node, varargin)
%SET Change a property of a virtual world node.
%   SET(N, PROPNAME, PROPERTYVALUE) changes a property of
%   the given VRNODE object.
%
%   SET(N, FIELDNAME, FIELDVALUE, FIELDNAME, FIELDVALUE, ...)
%   sets multiple property/value pairs.
%
%   Currently VRML nodes have no settable properties.
%   Property names are not case-sensitive.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2010/03/01 05:30:58 $ $Author: batserve $


% use this overloaded SET only if the first argument is VRNODE
if ~isa(node, 'vrnode')
  builtin('setfield',node,varargin{:});
  return;
end

% prepare pair of cell array of names and arguments
[propname, propval] = vrpreparesetargs(numel(node), varargin, 'property');

% loop through nodes
for i=1:size(propval, 1)
  
  % loop through property names
  for j=1:size(propval, 2)

    switch lower(propname{j})

      case {'fields', 'name', 'type', 'world'}
        error('VR:propreadonly', 'Node property ''%s'' is read-only.', propname{j});

      case {'parent'}
        warning('VR:obsoleteproperty', 'The ''Parent'' property is now obsolete. Please use ''World'' instead.');
        error('VR:propreadonly', 'Node property ''%s'' is read-only.', propname{j});

      case 'comment'
        % comment can be only string
        if ~ischar(propval{i,j})
          throwAsCaller(MException('VR:invalidinarg', '''Comment'' property argument must be a string.'));
        end
        % set node comment
        vrsfunc('SetNodeComment', get(node.World, 'id'), node(i).Name, propval{i,j}); 

      case {'newname'}
        % undocumented functionality -- node renaming
        vrsfunc('RenameNode', get(node.World, 'id'), node(i).Name, propval{i,j});
        node(i).Name = propval{i,j};

      otherwise
        warning('VR:obsoleteset', 'Using SET to set a field value is now obsolete. Please use SETFIELD instead.');
        setfield(node(i), propname{j}, propval{i,j});   %#ok this is overloaded SETFIELD

    end

  end
end
