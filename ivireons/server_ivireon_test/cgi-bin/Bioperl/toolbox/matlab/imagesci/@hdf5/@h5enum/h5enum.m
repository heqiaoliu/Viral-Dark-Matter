function hObj = h5enum(varargin)
%H5ENUM  Constructor for hdf5.h5enum objects
%
%   HDF5ENUM = hdf5.h5enum;
%
%   HDF5ENUM = hdf5.h5enum({'RED' 'GREEN' 'BLUE'}, uint8([1 2 3]));

%   $Revision: 1.1.6.3 $  $Date: 2005/11/15 01:08:25 $
%   Copyright 1984-2003 The MathWorks, Inc.

if (nargin == 3)
    hObj = hdf5.h5enum;
    hObj.defineEnum(varargin{2}, varargin{3});
    hObj.setData(varargin{1});

elseif (nargin == 2)
    hObj = hdf5.h5enum;
    hObj.defineEnum(varargin{:});

elseif (nargin == 0)
    hObj = hdf5.h5enum;

else
    error('MATLAB:h5enum:h5enum:badInputCount', ...
          'Incorrect number of arguments to constructor.')

end
