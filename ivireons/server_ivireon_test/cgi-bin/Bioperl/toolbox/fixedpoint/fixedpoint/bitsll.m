function Y = bitsll(A,K)
%BITSLL Shift Left Logical.
%   Y = BITSLL(A, K) performs a logical left shift by K bits on input
%   operand A.
%
%   The input operand A can be any numeric type, including double, single,
%   integer, or fixed-point. For fixed-point operations, the FIMATH
%   OverflowMode and RoundMode properties are ignored. BITSLL operates on
%   both signed and unsigned inputs.
%
%   K must be a scalar, integer-valued, and greater than or equal to zero.
%
%   K must also be less than the word length of A, when A is an integer or
%   fixed-point type.
%
%   See also BITSRL, BITSRA, BITSHIFT, POW2,
%            EMBEDDED.FI/BITSLL, EMBEDDED.FI/BITSRA, EMBEDDED.FI/BITSRL,
%            EMBEDDED.FI/BITSHIFT, EMBEDDED.FI/BITROR, EMBEDDED.FI/BITROL,
%            EMBEDDED.FI/BITSLICEGET, EMBEDDED.FI/BITCONCAT

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/12/28 04:11:47 $

error(nargchk(2,2,nargin,'struct'));

if ~isnumeric(K) || ~isscalar(K) || ~isequal(floor(K), K) || (K < 0)
    error('fi:bitsll:invalidshiftindex',...
        'K must be a scalar, integer-valued, and greater than or equal to zero in BITSLL(A,K).');
end

switch class(A)
  case {'double','single'}
    Y = pow2(double(K)).*A;
    
  case {'int8','uint8','int16','uint16','int32','uint32','int64','uint64'}
    % Save existing FIPREF settings
    P = fipref;
    PreviousDTOMode = P.DataTypeOverride;
    PreviousLogMode = P.LoggingMode;
    
    % Temporarily turn off data type override and logging modes
    P.DataTypeOverride = 'ForceOff';
    P.LoggingMode      = 'Off';
    
    % Perform bit shift operation on equivalent FI data type
    Y = int(bitsll(fi(A),K));
    
    % Restore previous FIPREF settings
    P.DataTypeOverride = PreviousDTOMode;
    P.LoggingMode      = PreviousLogMode;
    
  otherwise
    fn = mfilename;
    dt = class(A);
    errmsgid = sprintf('fixedpoint:fi:%s:%s:notallowed', fn, dt);
    error(errmsgid, 'Function ''%s'' is not defined for inputs of data type ''%s''.', fn, dt);
end
