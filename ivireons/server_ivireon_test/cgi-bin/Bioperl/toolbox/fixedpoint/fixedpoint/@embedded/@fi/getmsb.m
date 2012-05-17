function y = getmsb(x)
% GETMSB Get value of MSB
%
% SYNTAX
%   c = getmsb(a)
% 
% DESCRIPTION:
%   c = getmsb(a) returns the value of msb
%
%   This command is equivalent to 
%
%       nt = numerictype(a)
%       msbpos = nt.WordLength
%       c = bitsliceget(a, msbpos, msbpos)
%   
% 
%  See also EMBEDDED.FI/GETLSB,
%           EMBEDDED.FI/BITGET, EMBEDDED.FI/BITSET, EMBEDDED.FI/BITCONCAT, 
%           EMBEDDED.FI/BITAND, EMBEDDED.FI/BITOR, EMBEDDED.FI/BITXOR
%           EMBEDDED.FI/BITANDREDUCE, EMBEDDED.FI/BITORREDUCE,
%           EMBEDDED.FI/BITXORREDUCE
%           

% Error checking
error(nargchk(1,1,nargin,'struct'));

nt_x = numerictype(x); 
wl_x = nt_x.WordLength;

y = bitsliceget(x, wl_x, wl_x);