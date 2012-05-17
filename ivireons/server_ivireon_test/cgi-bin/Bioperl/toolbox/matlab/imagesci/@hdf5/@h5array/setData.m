function setData(hObj, data)
%SETDATA  Set the hdf5.h5array's data.
%
%   HDF5ARRAY = hdf5.h5array;
%   HDF5ARRAY.setData(magic(100));

%   $Revision: 1.1.6.3 $  $Date: 2005/11/15 01:08:17 $
%   Copyright 1984-2003 The MathWorks, Inc.

if isempty(data)
    hObj.Data = data;
    return
end

if (((~isnumeric(data)) && (~isa(data, 'hdf5.hdf5type'))) && ...
        (~iscell(data)))
    error('MATLAB:h5array:setData:badType', ...
          'Data must be numeric or a subclass of hdf5type or a cell.')
end

if (isa(data, class(data(1))))
    if iscell(data)
        hObj.Data = cell2mat(data);
    else
        hObj.Data = data;
    end
else
    error('MATLAB:h5array:setData:differentType', ...
          'All data elements must be of the same type.')
end
