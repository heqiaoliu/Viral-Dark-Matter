function [T, errid, errmsg] = computeDivideType(a, b) 
%computeDivideType Compute the quotient numerictype for A/B and A./B
%
%    T = computeDivideType(A,B) is a helper-function for RDIVIDE (A./B) and
%    MRDIVIDE (A/B).  The output numerictype T is a function of the
%    numerictypes of inputs A and B.
%
%    If both A and B are fixed-point types, then the output word length is
%    the maximum word length of A and B, and the output fraction length is
%    A.FractionLength - B.FractionLength.  If either A or B is Signed, then
%    the output will be Signed.  If both A and B are Unsigned, then the
%    output will be Unsigned.
%
%    Reference:
%    Simulink Fixed-Point User's Guide > Recommendations for Arithmetic and Scaling
%       > Division > Inherited Scaling for Speed
%       http://www.mathworks.com/access/helpdesk/help/toolbox/fixpoint/ug/f26557.html#f20147

%    Differences between Simulink and MATLAB.
%
%    Simulink: If either input is floating-point, then the output is
%    floating-point of the same type.  Double trumps over single. 
%    MATLAB: fi trumps over builtin types in mixed arithmetic.
%
%    Simulink: Fixed-point trumps over scaled-double.
%    MATLAB: Scaled-double trumps over fixed-point.

%   Thomas A. Bryan and Becky Bryan, 30 December 2008
%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/08/23 18:51:33 $


T = [];
errid = '';
errmsg = '';

if ~(isnumeric(a) && isnumeric(b))
    error('fi:divide:dataMustBeNumeric','Data must be numeric.');
end

if ~isreal(b)
    error('fi:rdivide:complexdenominator',...
          'In A./B and A/B, the denominator B must be real if either A or B is a fi object.');
end

% One or both inputs must be fi objects.

if isfi(a) && isslopebiasscaled(numerictype(a)) || ...
        isfi(b) && isslopebiasscaled(numerictype(b))
    % Error if slope-bias
    errid = 'fi:computeDivideType:SlopeBiasNotAllowed';
    errmsg = 'Function DIVIDE is only supported for FI object operands that have an integer power of 2 slope, and a bias of 0.';
elseif isfi(a) && ~isfi(b)
    if isscaledtype(a) && isinteger(b)
        % b is one of int8, uint8, int16, uint16, etc, so it is effectively
        % fixed-point.  Recurse once.
        [b,errid,errmsg] = integer_to_fi(b, a);
        if nargout<2 && ~isempty(errid)
            error(errid, errmsg);
        end
        T = computeDivideType(a,b);
    else
        % a is fi, b is not, so take the numerictype of a
        T = numerictype(a);
    end
elseif ~isfi(a) && isfi(b)
    if isscaledtype(b) && isinteger(a)
        % a is one of int8, uint8, int16, uint16, etc, so it is effectively
        % fixed-point.  Recurse once.
        [a,errid,errmsg] = integer_to_fi(a, b);
        if nargout<2 && ~isempty(errid)
            error(errid, errmsg);
        end
        T = computeDivideType(a,b);
    else
        % b is fi, a is not, so take the numerictype of b
        T = numerictype(b);
    end
    % From this point forward, we know that both a and b are fi objects.
elseif ~(isscaledtype(a) && isscaledtype(b)) && ...
        ~isequal(a.datatype, b.datatype)
    errid  = 'fixedpoint:fi:mixedmath';
    errmsg = 'Data type mismatches between fi object operands of the DIVIDE function are only allowed when the mismatch occurs between a ''Fixed'' and ''ScaledDouble'' data type.';
elseif isboolean(a) || isboolean(b)
    errid  = 'fixedpoint:fi:nobooleanmath';
    errmsg = 'Math operations are not allowed on FI objects with boolean data type.';
elseif isscaledtype(a) && isscaledtype(b)
    % Both are fixed-point or scaled-double.
    T = numerictype(a);
    T.Signed = a.Signed || b.Signed;
    T.WordLength = max(a.WordLength, b.WordLength);
    T.FractionLength = a.FractionLength - b.FractionLength;
    if isscaleddouble(a) || isscaleddouble(b)
        % Propagate scaled double
        T.datatype = 'ScaledDouble';
    end
elseif isscaledtype(a) 
    % Fixed-point and Scaled double trump.
    T = numerictype(a);
elseif isscaledtype(b)
    % Fixed-point and Scaled double trump.
    T = numerictype(b);
elseif isdouble(a) || isdouble(b)
    % Double trumps afer fixed-point and Scaled double.
    T = numerictype('datatype','double');
elseif issingle(a) || issingle(b)
    % Single trumps after double.
    T = numerictype('datatype','single');
else
    % In case other data types are added that are not covered in the above
    % cases. 
    errid = 'fi:computeDivideType:UnhandledCase';
    errmsg = 'Unable to compute output data type for fixed-point divide.';
end

% Return the error id and message if those outputs are defined.
% Otherwise, throw the error here.
if nargout<2 && ~isempty(errid)
    error(errid, errmsg);
end


function [y,errid,errmsg] = integer_to_fi(x, fi_obj)
% Convert builtin integer x to a fi object.  This makes the 
y = embedded.fi;
y.fimath = fimath(fi_obj);
y.FractionLength = 0;
errid = '';
errmsg = '';
switch class(x)
  case 'int8'
    y.Signed = true;
    y.WordLength = 8;
  case 'int16'
    y.Signed = true;
    y.WordLength = 16;
  case 'int32'
    y.Signed = true;
    y.WordLength = 32;
  case 'int64'
    y.Signed = true;
    y.WordLength = 64;
  case 'uint8'
    y.Signed = false;
    y.WordLength = 8;
  case 'uint16'
    y.Signed = false;
    y.WordLength = 16;
  case 'uint32'
    y.Signed = false;
    y.WordLength = 32;
  case 'uint64'
    y.Signed = false;
    y.WordLength = 64;
  otherwise
    errid = 'fi:computeDivideType:UnrecognizedIntegerType';
    errmsg = 'Unrecognized integer type in fixed-point divide.';
end


