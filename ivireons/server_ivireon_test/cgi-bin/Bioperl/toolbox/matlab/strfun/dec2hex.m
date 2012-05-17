function h = dec2hex(d,n)
%DEC2HEX Convert decimal integer to hexadecimal string.
%   DEC2HEX(D) returns a 2-D string array where each row is the
%   hexadecimal representation of each decimal integer in D.
%   D must contain non-negative integers smaller than 2^52.
%
%   DEC2HEX(D,N) produces a 2-D string array where each
%   row contains an N digit hexadecimal number.
%
%   Example
%       dec2hex(2748) returns 'ABC'.
%
%   See also HEX2DEC, HEX2NUM, DEC2BIN, DEC2BASE.

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 5.15.4.8 $  $Date: 2008/08/26 18:22:07 $

bits32 = 4294967296;       % 2^32

if nargin<1
    error(nargchk(1,2,nargin,'struct'));
end

d = d(:); % Make sure d is a column vector.

if ~isreal(d) || any(d < 0) || any(d ~= fix(d))
    error('MATLAB:dec2hex:FirstArgIsInvalid','First argument must contain non-negative integers.')
end
if any(d > 1/eps)
    warning('MATLAB:dec2hex:TooLargeArg',...
        ['At least one of the input numbers is larger than the largest',...
        'FLINT (2^52).\n         Results may be unpredictable.']);
end

numD = numel(d);

if nargin==1,
    n = 1; % Need at least one digit even for 0.
end

[f,e] = log2(double(max(d)));%#ok
n = max(n,ceil(e/4));
n0 = n;

if numD>1
    n = n*ones(numD,1);
end

%For small enough numbers, we can do this the fast way.
if all(d<bits32),
    h = sprintf('%0*X',[n,d]');
else
    %Division acts differently for integers
    d = double(d);
    d1 = floor(d/bits32);
    d2 = rem(d,bits32);
    h = sprintf('%0*X%08X',[n-8,d1,d2]');
end

h = reshape(h,n0,numD)';
