function DataType = sfix( TotalBits );
%SFIX Create structure describing Signed FIXed point data type
%
%    This data type structure can be passed to Simulink Blocks.
%
%    SFIX( TotalBits )
%
%    For example, SFIX(16) returns a MATLAB structure
%    that describes the data type of a 
%    16 bit Signed FIXed point number.
%
%    Note: A default radix point is not included in the data type
%    description.  The radix point would be given as a separate
%    block parameter that describes the scaling.
%
%    See also FIXDT, UFIX, SINT, UINT, SFRAC, UFRAC, FLOAT.
 
% Copyright 1994-2005 The MathWorks, Inc.
% $Revision: 1.7.2.4 $  
% $Date: 2005/06/24 11:11:02 $

DataType = struct('Class','FIX','IsSigned',1,'MantBits',TotalBits);
