function bEqual = H5MLcompare_values( value1, value2 )
%H5ML.compare_values Numerically compare two HDF5 values.
%   The compare_values function will compare two values, where either or
%   both values may be represented as a string.  The values are compared
%   numerically.
%
%   Function parameters:
%     bEqual: A logical value indicating whether the two values are equal.
%     value1: The first value to be compared.
%     value2: The second value to be compared.
%
%   Examples:
%     % See if the H5T copy function returns the input value:
%     a = H5T.copy('H5T_NATIVE_INT');
%     H5ML.compare_values(a, 'H5T_NATIVE_INT')
%

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/05/14 17:11:06 $

if isa(value1, 'char')
  value1 = H5ML.get_constant_value(value1);
end
if isa(value2, 'char')
  value2 = H5ML.get_constant_value(value2);
end
bEqual = H5ML.hdf5lib2('H5MLcompare_values', value1, value2);
