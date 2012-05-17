function setEnumNames(hObj, stringValues)
%SETENUMNAMES  Set the hdf5.h5enum's string values.
%
%   HDF5ENUM.setEnumNames({'ALPHA' 'RED' 'GREEN' 'BLUE'});

%   $Revision: 1.1.6.3 $  $Date: 2005/11/15 01:08:28 $
%   Copyright 1984-2003 The MathWorks, Inc.

if (~iscellstr(stringValues))
    error('MATLAB:h5enum:setEnumNames:nameValueType', ...
          'Name values must be strings.');
    
elseif (numel(stringValues) ~= length(stringValues))
    error('MATLAB:h5enum:setEnumNames:nameValueRank', ...
          'Name values must be vectors.');
    
end

hObj.EnumNames = stringValues;
