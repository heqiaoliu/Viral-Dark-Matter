function setEnumValues(hObj, numberValues)
%SETENUMVALUES  Set the hdf5.h5enum's numeric values.
%
%   HDF5ENUM = hdf5.h5enum;
%   HDF5ENUM.setEnumNames({'ALPHA' 'RED' 'GREEN' 'BLUE'});
%   HDF5ENUM.setEnumValues(uint8([0 1 2 3]));

%   $Revision: 1.1.6.3 $  $Date: 2005/11/15 01:08:29 $
%   Copyright 1984-2003 The MathWorks, Inc.

if (~isnumeric(numberValues))
    error('MATLAB:h5enum:setEnumValues:wrongType', ...
          'Enumeration definition values must be numeric.');
    
elseif ((isa(numberValues, 'single')) || (isa(numberValues, 'double')))
    error('MATLAB:h5enum:setEnumValues:notIntegral', ...
          'Enumeration definition values must be integers.')

elseif (numel(numberValues) ~= length(numberValues))
    error('MATLAB:h5enum:setEnumValues:valueRank', ...
          'Enumeration definition values must be vectors.');
    
end

hObj.EnumValues = numberValues;
