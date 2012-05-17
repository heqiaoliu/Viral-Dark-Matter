function C = reinterpretcast(A, T)
%REINTERPRETCAST Convert fixed-point or integer data types without changing underlying data
%   C = REINTERPRETCAST(A, T) converts the input (integer or fi object) A
%   to the data type specified by numerictype object T, without changing
%   the underlying (stored integer) data. The result is returned in C.
%
%   The data type of the input A must be fixed point or integer. T must be
%   a numerictype object with a fully specified fixed-point data type.  The
%   word length of inputs A and T must be the same.
%
%   The REINTERPRETCAST function differs from the MATLAB TYPECAST and CAST
%   functions, in that it only operates on fi and integer types, and it
%   does not allow the word length of the input to change.
%
%   EXAMPLE:
%     %% Convert from signed 8,7 to unsigned 8,0.
%     a = fi([-1 pi/4], true, 8, 7)
%     %   returns [-1.0000    0.7891] s8,7
%     
%     T = numerictype(false, 8, 0);
%     b = reinterpretcast(a, T)
%     %   returns [128   101] u8,0
%     
%     % Their binary representations are identical
%     binary_rep = [bin(a);bin(b)]
%     %    returns 10000000   01100101
%     %            10000000   01100101
%
%   See also FI, NUMERICTYPE, TYPECAST, CAST.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/04/21 03:18:13 $

switch class(A)
  case {'int8','uint8','int16','uint16','int32','uint32','int64','uint64'}
    FI_int = fi(A);
    if ~isequal(FI_int.WordLength, T.WordLength)
        fn        = mfilename;
        dt        = class(A);
        errmsgid  = sprintf('fixedpoint:fi:%s:%s:wlmismatch', fn, dt);
        error(errmsgid, 'In calls to REINTERPRETCAST(A, T), the word length of A and T must match. Presently, A is of data type ''%s'' and T.WordLength is %d.', dt, T.WordLength);
    else
        C = reinterpretcast(FI_int, T);
    end
  otherwise
    fn = mfilename;
    dt = class(A);
    errmsgid = sprintf('fixedpoint:fi:%s:%s:notallowed', fn, dt);
    error(errmsgid, 'Function ''%s'' is not defined for inputs of data type ''%s''.', fn, dt);
end
