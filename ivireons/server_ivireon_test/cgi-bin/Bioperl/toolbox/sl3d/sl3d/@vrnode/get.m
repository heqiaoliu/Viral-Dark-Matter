function y = get(node, propertyname)
%GET Get a property of VRNODE.
%   Y = GET(NODE, 'propertyname') returns the value of the specified
%   property for the node referenced by the VRNODE handle NODE. If
%   NODE is a vector of VRNODE handles, then GET will return an
%   M-by-1 cell array of values where M is equal to LENGTH(NODE).
%   If 'propertyname' is a 1-by-N or N-by-1 cell array of strings containing
%   field names, then GET will return an M-by-N cell array of
%   values. If 'propertyname' is not specified, all properties are
%   printed.
%
%   Y = GET(NODE) where NODE is a scalar, returns a structure where
%   each field name is the name of a property and each field contains
%   the value of that property.
%
%   Valid properties are (property names are case-insensitive):
%
%     'Comment' (settable)
%        Node comment stored in the embracing VRML file.
%
%     'Fields' (read-only)
%        Valid field names for this type of VRML node.
%
%     'Name' (read-only)
%        Node name.
%
%     'Type' (read-only)
%        Node type.
%
%     'World' (read-only)
%        A VRWORLD handle referencing the parent virtual world.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2010/03/01 05:30:55 $ $Author: batserve $


% use this overloaded GET only if the first argument is VRNODE
if ~isa(node, 'vrnode')
  builtin('get',node,propertyname);
  return
end

% if no name given return all properties
if nargin<2
  if length(node)>1 && nargout==0
    error('VR:invalidinarg', 'Vector of VRNODEs is not allowed if there is no output parameter.');
  end
  propertyname = {'Comment', 'Fields', 'Name', 'Type', 'World'};
end

% validate PROPERTYNAME
if ischar(propertyname) 
  propertyname = {propertyname};
elseif ~iscellstr(propertyname)
  error('VR:invalidinarg', 'PROPERTYNAME must be a string or a cell array of strings.');
end

% initialize variables
y = cell(numel(node), numel(propertyname));

% loop through nodes
for i=1:size(y, 1)
  wid = getparentid(node(i));
  
  % loop through property names
  for j=1:size(y, 2)
    switch lower(propertyname{j})
      case 'comment'
        % get node comment
        y{i,j} = vrsfunc('GetNodeComment', wid, node(i).Name);

      case 'fields'
        fieldlist = vrsfunc('VRT3ListNodeFields', wid, node(i).Name);
        y{i,j} = fieldlist(:,1);
  
      % return the complete field structure
      % undocumented - use FIELDS instead
      case 'fieldstruct'
        offon = {'off', 'on'};
        fieldlist = vrsfunc('VRT3ListNodeFields', wid, node(i).Name);
        for k=1:size(fieldlist,1)
          result.(fieldlist{k,1}) = struct('Type', fieldlist{k,2}, ...
                                           'Access', fieldlist{k,3}, ...
                                           'Sync', offon(vrsfunc('GetWatch', wid, node(i).Name, fieldlist{k,1}) + 1) ...
                                          );
        end
        
        if (size(fieldlist,1)==0)
          % result may not exist
          y{i,j} = []; 
        else
          y{i,j} = result;
        end
        
      case 'name'
        y{i,j} = getname(node(i).Name);
        
      case 'internalname'
        y{i,j} = node(i).Name;        

      case 'type'
        y{i,j} = vrsfunc('VRT3NodeType', wid, node(i).Name);
  
      case 'world'
        y{i,j} = node(i).World;

      % get a field value - obsolete
      otherwise
        warning('VR:obsoleteget', 'Using GET to get a field value is now obsolete. Please use GETFIELD instead.');
        y{i,j} = getfield(node(i), propertyname{j});   %#ok this is overloaded GETFIELD

    end
  end
end

% convert to structure if getting all the properties
if nargin < 2
  y = cell2struct(y, propertyname, 2);

  % if no output arguments just print the result
  if nargout == 0
    vrprintval(y);
    clear y;
  end

% handle the scalar case
elseif length(y) == 1
  y = y{1};
end
