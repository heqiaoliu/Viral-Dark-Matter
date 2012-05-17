function DataType = uint( TotalBits );
%UINT Create structure describing Unsigned INTeger data type
%
%    This data type structure can be passed to Simulink Blocks.
%
%    UINT( TotalBits )
%
%    For example, UINT(16) returns a MATLAB structure
%    that describes the data type of a 
%    16 bit Unsigned INTeger number.
%
%    Note: for integer types, the radix point is just
%    to the right of all bits.
%
%    See also FIXDT, SFIX, UFIX, SINT, SFRAC, UFRAC, FLOAT.
 
% Copyright 1994-2005 The MathWorks, Inc.
% $Revision: 1.7.2.4 $  
% $Date: 2005/06/24 11:11:41 $

DataType = struct('Class','INT','IsSigned',0,'MantBits',TotalBits);
