function precision = fixptbestprec( RealWorldValue, TotalBits, IsSigned );
%FIXPTBESTPREC  Determine the maximum precision that can be used in
%            the fixed point representation of a value.
% Usage:
%   precision = FIXPTBESTPREC( RealWorldValue, TotalBits, IsSigned )
% or
%   precision = FIXPTBESTPREC( RealWorldValue, FixPtDataType )
%
%  The maximum precision (power of 2) fixed point representation is based
%  on the formula
%     RealWorldValue = StoredInteger * precision
%  where StoredInteger is an integer with a specified size and  
%  signed/unsigned status and precision is restricted to being a power of 2.
%
%  For example, 
%      fixptbestprec(4/3,8,1) 
%  or
%      fixptbestprec(4/3,sfix(8))
%  would return
%      0.015625 = 2^-6.  
%  This says that if a signed eight bit number is used then the maximum 
%  precision representation of 
%      1.33333333333333 (base 10) 
%  is 
%      85 * 0.015625 = 85 * 2^6 
%                    = 01.010101 (base 2) 
%                    =  1.328125 (base 10)
%  The precision can be used as the scaling parameter in Fixed Point Blocks.
%
%  See also SFIX, UFIX, FIXPTBESTEXP



% Copyright 1994-2007 The MathWorks, Inc.
% $Revision: 1.7.2.1 $  
% $Date: 2007/03/21 00:57:45 $

if nargin < 2
    DAStudio.error('Shared:numericType:fixptbest1');
elseif nargin < 3
    precision = 2.^bestfixexp(RealWorldValue, double(TotalBits.MantBits), ...
                                              double(TotalBits.IsSigned));
else
    precision = 2.^bestfixexp(RealWorldValue, double(TotalBits), double(IsSigned));
end    
