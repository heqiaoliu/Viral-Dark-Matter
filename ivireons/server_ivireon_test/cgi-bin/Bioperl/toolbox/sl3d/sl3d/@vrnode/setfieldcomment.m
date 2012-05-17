function setfieldcomment(node, varargin)
%SETFIELDCOMMENT Change a field comment of VRNODE.
%   SETFIELDCOMMENT(NODE, FIELDNAME, FIELDCOMMENT) changes a field comment of the node
%   associated with the given VRNODE object.
%
%   SETFIELDCOMMENT(N, FIELDNAME, FIELDCOMMENT, FIELDNAME, FIELDCOMMENT, ...)
%   sets multiple field/comment or field/comment pairs.
%
%   VRML field names are case-sensitive, while property names
%   are not.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2010/03/01 05:30:59 $ $Author: batserve $


if ~isa(node, 'vrnode')
 throwAsCaller(MException('VR:invalidinarg', 'First argument must be a VRNODE.'));
end

% check for invalid nodes
if ~all(isvalid(node))
  throwAsCaller(MException('VR:invalidnode', 'Invalid node.'));
end

% prepare cell array pair of names and arguments
[fieldname, fieldcomment] = vrpreparesetargs(numel(node), varargin, 'field');

% loop through nodes
for i=1:size(fieldcomment, 1)  
  % loop through fieldnames
  for j=1:size(fieldcomment, 2)  
    % comment can be only string
    if ~ischar(fieldcomment{i})
      throwAsCaller(MException('VR:invalidinarg', '''Comment'' property value must be a string.'));
    end    
    % set the field comment
    vrsfunc('SetFieldComment', getparentid(node(i)), node(i).Name, fieldname{j}, fieldcomment{i,j});
  end
end
