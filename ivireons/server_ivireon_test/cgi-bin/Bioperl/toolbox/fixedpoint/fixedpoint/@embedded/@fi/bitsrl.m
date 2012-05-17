function y = bitsrl(x,kin)
%BITSRL Shift Right Logical.
%   Y = BITSRL(A, K) performs a logical right shift by K bits on input
%   operand A.
%
%   The input operand A can be integer or fixed-point. For fixed-point
%   operations, the FIMATH OverflowMode and RoundMode properties are
%   ignored. BITSRL operates on both signed and unsigned inputs, and shifts
%   zeros into the positions of bits that it shifts right (regardless of
%   the sign of the input).
%
%   K must be a scalar, integer-valued, and greater than or equal to zero.
%
%   K must also be less than the word length of A, when A is an integer or
%   fixed-point type.
%
%   See also BITSRL, BITSRA, BITSLL, BITSHIFT, POW2,
%            EMBEDDED.FI/BITSRA, EMBEDDED.FI/BITSLL,
%            EMBEDDED.FI/BITSHIFT, EMBEDDED.FI/BITROR, EMBEDDED.FI/BITROL,
%            EMBEDDED.FI/BITSLICEGET, EMBEDDED.FI/BITCONCAT

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/04/21 03:18:20 $

error(nargchk(2,2,nargin,'struct'));

kin = double(kin);

if ~isscalar(kin) || ~isequal(floor(kin), kin) || (kin < 0)
    error('fi:bitsrl:invalidshiftindex',...
        'K must be a scalar, integer-valued, and greater than or equal to zero in BITSRL(A,K).');
end

if isequal(kin, 0)
    y = x;
else
    fm = fimath(x);
    nt = numerictype(x);
    
    if (nt.WordLength == 1)
        error('fi:bitsrl:invalidinput',...
            'BITSRL is not defined for 1-bit input operands.');
    end
    
    if (kin >= (nt.WordLength))
        error('fi:bitsrl:invalidshiftindex',...
            'K must be less than the word length of the input operand A in BITSRL(A,K).');
    end
    
    if isscaleddouble(x)
        % Recursion
        nt.datatype = 'Fixed';
        xfp = fi(double(x), nt, fm);
        yfp = bitsrl(xfp, kin);
        y   = fi(double(yfp), numerictype(x), fm);
        
    elseif isfixed(x)
        % do shift without saturation or rounding
        a = x;
        a.RoundMode = 'floor';
        a.OverflowMode = 'wrap';
        y = bitshift(a, -kin);
        
        % fill in msbs with zeros
        for ii=0:kin-1
            y = bitset(y, (nt.WordLength)-ii, 0);
        end
    else
        % non fi-fixedpoint not supported
        dt = x.dataType;
        fn = mfilename;
        errmsgid = sprintf('fixedpoint:fi:%s:%s:notallowed', fn,dt);
        error(errmsgid, 'Function ''%s'' is not defined for FI objects of data type ''%s''',fn,dt);
    end
    
    % restore fimath
    if (isfimathlocal(x))
        y.fimath = fm;
    else
        y.fimathislocal = false;
    end
end
