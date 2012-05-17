function Y = bitsra(A,K)
%BITSRA Shift Right Arithmetic.
%   Y = BITSRA(A, K) performs an arithmetic right shift by K bits on input
%   operand A.
%
%   The input operand A can be any numeric type, including double, single,
%   integer, or fixed-point. For fixed-point operations, the FIMATH
%   OverflowMode and RoundMode properties are ignored. BITSRA operates on
%   both signed and unsigned inputs.
%
%   If the input is unsigned, BITSRA shifts zeros into the positions of
%   bits that it shifts right. If the input is signed, BITSRA shifts the
%   MSB into the positions of bits that it shifts right.
%
%   K must be a scalar, integer-valued, and greater than or equal to zero.
%
%   K must also be less than the word length of A, when A is an integer or
%   fixed-point type.
%
%   See also BITSLL, BITSRL, BITSHIFT, POW2,
%            EMBEDDED.FI/BITSRA, EMBEDDED.FI/BITSLL, EMBEDDED.FI/BITSRL,
%            EMBEDDED.FI/BITSHIFT, EMBEDDED.FI/BITROR, EMBEDDED.FI/BITROL,
%            EMBEDDED.FI/BITSLICEGET, EMBEDDED.FI/BITCONCAT

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/04/21 03:18:04 $

error(nargchk(2,2,nargin,'struct'));

if ~isnumeric(K) || ~isscalar(K) || ~isequal(floor(K), K) || (K < 0)
    error('fi:bitsra:invalidshiftindex',...
        'K must be a scalar, integer-valued, and greater than or equal to zero in BITSRA(A,K).');
end

switch class(A)
  case {'double','single'}
    Y = pow2(-double(K)).*A;
    
  case {'int8','uint8','int16','uint16','int32','uint32','int64','uint64'}
    % Save existing FIPREF settings
    P = fipref;
    PreviousDTOMode = P.DataTypeOverride;
    PreviousLogMode = P.LoggingMode;
    
    % Temporarily turn off data type override and logging modes
    P.DataTypeOverride = 'ForceOff';
    P.LoggingMode      = 'Off';
    
    % Perform bit shift operation on equivalent FI data type
    Y = int(bitsra(fi(A),K));
    
    % Restore previous FIPREF settings
    P.DataTypeOverride = PreviousDTOMode;
    P.LoggingMode      = PreviousLogMode;
    
  otherwise
    fn = mfilename;
    dt = class(A);
    errmsgid = sprintf('fixedpoint:fi:%s:%s:notallowed', fn, dt);
    error(errmsgid, 'Function ''%s'' is not defined for inputs of data type ''%s''.', fn, dt);
end
