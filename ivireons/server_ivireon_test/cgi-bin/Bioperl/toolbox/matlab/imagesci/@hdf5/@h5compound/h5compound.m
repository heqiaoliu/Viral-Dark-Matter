function hObj = h5compound(varargin)
%H5COMPOUND  Constructor.

% Copyright 2003 The MathWorks, Inc.

if (~isempty(varargin))
    hObj = hdf5.h5compound;
    hObj.setMemberNames(varargin{:});
else
    hObj = hdf5.h5compound;
end
