function setMemberNames(hObj, varargin)
%SETMEMBERNAMES  Set the names of the compound object's members.

%   $Revision: 1.1.6.3 $  $Date: 2005/11/15 01:08:22 $
%   Copyright 1984-2003 The MathWorks, Inc.

if (~iscellstr(varargin))
    error('MATLAB:h5compound:setMemberNames:badNameType', ...
          'Member names must be strings.')
end

for p = 1:(nargin - 1)
    disp(sprintf('Adding member "%s"', varargin{p}))
    hObj.addMember(varargin{p});
end
