function y = bitror(a,kin)
% BITROR Rotate Right
%
% SYNTAX
%   C = BITROR(A, ROTATE_LEN)
% 
% DESCRIPTION:
%   C = BITROR(A, ROTATE_LEN) Performs rotate right on stored integer bits 
%   of input operand a. 
%
%   1)	Requires a fixed point input operand.
%   2)	ROTATE_LEN must be integer constant >= 0
%   3)	Both unsigned and signed fixed point inputs are rotated right 
%       and there is no overflow/underflow check
%   4)  The OverflowMode and RoundMode properties are ignored
%   5)  Input and Output have same numeric type and fimath properties
%   6)  ROTATE_LEN can be greater than wordlength of A
%   7)  ROTATE_LEN is always normalized to 'mod(wlen(A), ROTATE_LEN)'
%
%  See also EMBEDDED.FI/BITROL, EMBEDDED.FI/BITSHIFT
%           EMBEDDED.FI/BITSLL, EMBEDDED.FI/BITSRL, EMBEDDED.FI/BITSRA,            
%           EMBEDDED.FI/BITSLICEGET, EMBEDDED.FI/BITCONCAT

%   Copyright 2007-2009 The MathWorks, Inc.

% Error checking
error(nargchk(2,2,nargin,'struct'));
if (kin < 0)
    error('fi:bitror:invalidshiftindex',...
        'rotate index should be greater than zero');
end

if (~isscalar(kin))
    error('fi:bitror:invalidshiftindex',...
        'K must be scalar in BITROR(A,K) when A is a FI object');
end

    
nt_a = numerictype(a); 
wl_a = nt_a.WordLength;

if (nt_a.WordLength == 1)
    error('fi:bitror:invalidinput',...
        'bitror not defined for 1 bit operands');
end

if (kin == 0)
    y = a;
    return;
end


% normalize rotate index
kin = mod(kin, wl_a);

if (kin == 0)
    y = a;
    return;
end

% x >>> n | x << wl - n
t1 = bitsrl(a, kin);
t2 = bitsll(a, wl_a - kin);
y = bitor(t1, t2);

