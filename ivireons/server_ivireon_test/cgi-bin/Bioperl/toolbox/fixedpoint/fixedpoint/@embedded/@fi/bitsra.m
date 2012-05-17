function y = bitsra(x,kin)
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
%   See also BITSRA, BITSLL, BITSRL, BITSHIFT, POW2,
%            EMBEDDED.FI/BITSLL, EMBEDDED.FI/BITSRL,
%            EMBEDDED.FI/BITSHIFT, EMBEDDED.FI/BITROR, EMBEDDED.FI/BITROL,
%            EMBEDDED.FI/BITSLICEGET, EMBEDDED.FI/BITCONCAT

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/04/21 03:18:19 $

error(nargchk(2,2,nargin,'struct'));

kin = double(kin);

if ~isscalar(kin) || ~isequal(floor(kin), kin) || (kin < 0)
    error('fi:bitsra:invalidshiftindex',...
        'K must be a scalar, integer-valued, and greater than or equal to zero in BITSRA(A,K).');
end

if isequal(kin, 0)
    y = x;
else
    nt = numerictype(x);
    
    if (nt.WordLength == 1)
        error('fi:bitsra:invalidinput',...
            'BITSRA is not defined for 1-bit input operands.');
    end
    
    if isnumeric(x)
        if isfixed(x)
            if (kin >= (nt.WordLength))
                error('fi:bitsra:invalidshiftindex',...
                    'K must be less than the word length of the input operand A in BITSRA(A,K).');
            end
            % do shift without saturation or rounding
            a = x;
            a.RoundMode = 'floor';
            a.OverflowMode = 'wrap';
            y = bitshift(a, -kin);
        else
            % x is a (real or complex) floating-point or scaled-double FI
            y_dbl = double(x) .* pow2(-double(kin));
            
            % Preserve the numeric type and fimath of x for output
            y = fi(y_dbl, nt, fimath(x));
            
            if isscaleddouble(x)
                P = fipref;
                if ~strcmpi(P.LoggingMode, 'off')
                    % Re-run the BITSRA operation on fixed-point
                    % type to report possible overflow/underflow
                    nt.datatype = 'Fixed';
                    xfp = fi(double(x), nt, fimath(x));
                    yfp = bitsra(xfp, kin); %#ok
                end
            end
        end
        
        % restore fimath
        if (isfimathlocal(x))
            y.fimath = fimath(x);
        else
            y.fimathislocal = false;
        end
    else
        % non-numeric fi (not supported)
        dt = x.dataType;
        fn = mfilename;
        errmsgid = sprintf('fixedpoint:fi:%s:%s:notallowed', fn,dt);
        error(errmsgid, 'Function ''%s'' is not defined for FI objects of data type ''%s''',fn,dt);
    end
end
