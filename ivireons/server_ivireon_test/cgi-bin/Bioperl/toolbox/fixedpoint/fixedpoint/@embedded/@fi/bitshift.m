%BITSHIFT Shift bits specified number of places
%   C = BITSHIFT(A, K) returns the value of A shifted by K bits, in fi
%   object C.  fi object A can be any fixed-point numeric type, and may
%   either be a scalar or a vector. K must be a scalar with built-in type.
%   The OverflowMode property is obeyed. The RoundMode is always floor. 
%   BITSHIFT only supports fi objects with fixed-point data types.
%
%   Examples: Changing results of BITSHIFT with OverflowMode settings:
%       % 1. By default, the OverflowMode fimath property is saturate. 
%       % When A is shifted such that it overflows, it is saturated to the 
%       % maximum possible value:
%       a = fi(3,1,16,0);
%       for k=0:16,
%           b=bitshift(a,k);
%           disp([num2str(k,'%02d'),'. ',bin(b)]);
%       end
%
%       % 2.Now change OverflowMode to wrap.
%       % In this case, most significant bits shift off the "top" of A until
%       % the value is zero:
%       a = fi(3,1,16,0,'OverflowMode','wrap');
%       for k=0:16,
%           b=bitshift(a,k);
%           disp([num2str(k,'%02d'),'. ',bin(b)]);
%       end
%
%   See also EMBEDDED.FI/BITSLL, EMBEDDED.FI/BITSRL, EMBEDDED.FI/BITSRA,
%            EMBEDDED.FI/BITROL, EMBEDDED.FI/BITROR,
%            EMBEDDED.FI/BITAND, EMBEDDED.FI/BITCMP, EMBEDDED.FI/BITGET, 
%            EMBEDDED.FI/BITOR, EMBEDDED.FI/BITSET, EMBEDDED.FI/BITXOR

%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/04/14 19:34:47 $
