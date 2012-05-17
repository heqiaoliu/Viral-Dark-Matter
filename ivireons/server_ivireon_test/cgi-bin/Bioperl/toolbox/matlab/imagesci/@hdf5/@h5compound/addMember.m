function addMember(hObj, varargin)
%ADDMEMBER  Add a new member to a compound object.

%   $Revision: 1.1.6.3 $  $Date: 2005/11/15 01:08:18 $
%   Copyright 1984-2003 The MathWorks, Inc.

if (nargin == 1)
    error('MATLAB:h5compound:addMember:missingName', ...
          'You must specify a member name.')

elseif (nargin == 2)
    memberName = varargin{1};
    data = [];
    
elseif (nargin == 3)
    memberName = varargin{1};
    data = varargin{2};
    
else
    error('MATLAB:h5compound:addMember:tooManyInputs', ...
          'Too many input arguments.')
    
end


if (~ischar(memberName))
    error('MATLAB:h5compound:addMember:badNameType', ...
          'Member name must be a string.')

elseif (isempty(memberName))
    error('MATLAB:h5compound:addMember:emptyName', ...
          'Member names cannot be empty.')

elseif (any(strcmp(hObj.MemberNames, memberName)))
    error('MATLAB:h5compound:addMember:existingName', ...
          'Member "%s" already exists.', memberName)
    
end

hObj.MemberNames{end + 1} = memberName;
hObj.setMember(memberName, data)
