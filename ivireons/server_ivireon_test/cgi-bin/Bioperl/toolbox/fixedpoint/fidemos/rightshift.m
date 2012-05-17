function y = rightshift(x, n)
%RIGHTSHIFT  Arithmetic right-shift.
%   RIGHTSHIFT will be removed in a future release. Use BITSRA instead.
%   Y = RIGHTSHIFT(X, N) simply calls Y = BITSRA(X, N) to perform an
%   arithmetic-right-shift of data X by N bits. If X is not a fixed-point
%   or builtin integer data type, then this function returns X*(2^-N).
%
%   See also BITSRA.

%   Copyright 2004-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $
%#eml
warning('fixedpoint:rightshift:DeprecatedFunction', ...
   'RIGHTSHIFT will be removed in a future release. Use BITSRA instead.');
y = bitsra(x, n);
