function hObj = h5array(varargin)
%H5ARRAY  Constructor for hdf5.h5array objects
%
%   hdf5array = hdf5.h5array;
%
%   hdf5array = hdf5.h5array(magic(5));

%   $Revision: 1.1.6.3 $  $Date: 2005/11/15 01:08:15 $ 
%   Copyright 1984-2003 The MathWorks, Inc.

if (nargin == 1)
    hObj = hdf5.h5array;
    hObj.setData(varargin{1});
elseif (nargin == 0)
    hObj = hdf5.h5array;
else
    error('MATLAB:h5array:h5array:tooManyInputs', ...
          'Too many arguments to constructor.')
end
