function setMember(hObj, memberName, data)
%hdf5.h5compound.setMember  Update a member's data.
%
%   Example:
%       hobj = hdf5.h5compound('a','b','c');
%       hobj.setMember('a',0);
%       hobj.setMember('b',uint32(1));
%       hobj.setMember('c',int32(2));
%       hdf5write('myfile.h5','ds1',hobj);

% Copyright 2003-2010 The MathWorks, Inc.

idx = strcmp(hObj.MemberNames, memberName);

if (~any(idx))
    error('MATLAB:h5compound:setMember:badName', ...
          'Invalid member name.')
end

if ((~isnumeric(data)) && (~isa(data, 'hdf5.hdf5type')))
    error('MATLAB:h5compound:setMember:badType', ...
          'Data must be numeric or a subclass of hdf5type.')
elseif (numel(data) > 1)
    error('MATLAB:h5compound:setMember:badSize', ...
          'Data must contain a single value.')
end

hObj.Data{idx} = data;
