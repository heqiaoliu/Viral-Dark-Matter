function DataType = ufix( TotalBits );
%UFIX Create structure describing Unsigned FIXed point data type
%
%    This data type structure can be passed to Simulink Blocks
%
%    UFIX( TotalBits )
%
%    For example, UFIX(16) returns a MATLAB structure
%    that describes the data type of a 
%    16 bit Unsigned FIXed point number.
%
%    Note: A default radix point is not included in the data type
%    description.  The radix point would be given as a separate
%    block parameter that describes the scaling.
%
%    See also FIXDT, SFIX, SINT, UINT, SFRAC, UFRAC, FLOAT.

% Copyright 1994-2005 The MathWorks, Inc.
% $Revision: 1.7.2.4 $  
% $Date: 2005/06/24 11:11:39 $

DataType = struct('Class','FIX','IsSigned',0,'MantBits',TotalBits);

