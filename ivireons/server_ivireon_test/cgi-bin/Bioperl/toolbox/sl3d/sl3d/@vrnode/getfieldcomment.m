function y = getfieldcomment(node, fieldname)
%GETFIELDCOMMENT Get a field comment of VRNODE.
%   Y = GETFIELDCOMMENT(NODE, 'fieldname') returns the comment of the specified
%   field for the node referenced by the VRNODE handle NODE. If
%   NODE is a vector of VRNODE handles, then GETFIELDCOMMENT will return
%   an M-by-1 cell array of comments where M is equal to LENGTH(NODE).
%   If 'fieldname' is a 1-by-N or N-by-1 cell array of strings containing
%   field names, then GETFIELDCOMMENT will return an M-by-N cell array of
%   comments.
%
%   GETFIELDCOMMENT(NODE) displays all field names and their current comments for
%   the VRML node with handle NODE.
%
%   Y = GETFIELDCOMMENT(NODE) where NODE is a scalar, returns a structure where
%   each field name is the name of a field of NODE and each field contains
%   the comment of that field.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2010/03/01 05:30:57 $ $Author: batserve $


if ~isa(node, 'vrnode')
 throwAsCaller(MException('VR:invalidinarg', 'First argument must be a VRNODE.'));
end

% if no name given return all fields
if nargin<2
  if length(node)>1
    error('VR:invalidinarg', 'Vector of nodes not allowed if field name not given.');
  end
  
  % get the list of fields, 
  % select only the fields which can have comment
  fieldstruct = fields(node);
  fieldlist = fields(fieldstruct);
  filtered_fieldlist = {};
  for i=1:numel(fieldlist)
    acc = fieldstruct.(fieldlist{i}).Access;
    % only (exposed) fields can be commented inside the node, but with one
    % exception -- Script nodes can have commented even eventIns and eventOuts
    if any(strcmp(acc, {'exposedField', 'field'})) || strcmp(get(node, 'Type'), 'Script')
      filtered_fieldlist = [filtered_fieldlist fieldlist(i)];   %#ok<AGROW> size not known in advance
    end
  end
  
  % use the whole list as field names
  fieldname = filtered_fieldlist;
end

% validate FIELDNAME
if ischar(fieldname) 
  fieldname = {fieldname};
elseif ~iscellstr(fieldname)
  error('VR:invalidinarg', 'Field name must be a string or a cell array of strings.');
end

% initialize variables
y = cell(numel(node), numel(fieldname));

% loop through nodes
for i=1:size(y, 1)
  wid = getparentid(node(i));
  % loop through fieldnames
  for j=1:size(y, 2)
    % read the field comment
    y{i,j} = vrsfunc('GetFieldComment', wid, node(i).Name, fieldname{j});
  end
end

% convert to structure if getting all the fields
if nargin < 2
  y = cell2struct(y, fieldname, 2);

  % if no output arguments just print the result
  if nargout == 0
    vrprintval(y);
    clear y;
  end

% handle the scalar case
elseif numel(y) == 1
  y = y{1};
end
