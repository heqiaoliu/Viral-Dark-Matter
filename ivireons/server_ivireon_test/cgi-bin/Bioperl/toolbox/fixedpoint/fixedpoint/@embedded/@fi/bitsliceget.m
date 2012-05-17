function y = bitsliceget(x,left_idx,right_idx)
% BITSLICEGET Get a consecutive set of bits from the stored int
%  representation of fi
%
% SYNTAX
%   c = bitsliceget(a, left_idx, right_idx)
%   c = bitsliceget(a, left_idx)
%   c = bitsliceget(a)
%
% DESCRIPTION:
%   c = bitsliceget(a, left_idx, right_idx) returns the value of the bits
%       in 'a' starting at position 'right_idx' to 'left_idx'.
%
%   1) Requires fixed point input operand
%   2)	Indices must satisfy the condition
%          wordlength(a)  >= left_idx >= right_idx >= 1
%   3)	If 'a' has a signed numerictype, then the bit representation of the
%       stored integer is in two's complement representation.
%   4)	Bitsliceget only supports fi objects with fixed-point data types.
%   5)	Bitsliceget behaves exactly like bitget when slicing one bit
%       (when left_idx and right_idx have same numeric value)
%   6)	Bitsliceget supports variable indexing  when slicing only one bit
%       (left_idx and right_idx should use same variable name)
%   7)	Bitsliceget supports vector type for input operand 'a'
%   8)	Left_idx and right_idx should be scalar constants
%   9)	If left_idx is not specified then left_idx defaults to wordlength(a)
%   10)	If right_idx is not specified then right_idx defaults to 1
%   11)	The return type of bitsliceget is always ufixN with no scaling and
%       and word length equal to slice length (left_idx - right_idx + 1)
%   12) Does not support complex inputs
%
%  See also EMBEDDED.FI/BITGET, EMBEDDED.FI/BITSET, EMBEDDED.FI/BITCONCAT,
%           EMBEDDED.FI/BITAND, EMBEDDED.FI/BITOR, EMBEDDED.FI/BITXOR
%           EMBEDDED.FI/BITANDREDUCE, EMBEDDED.FI/BITORREDUCE,
%           EMBEDDED.FI/BITXORREDUCE
%

%   Copyright 2007-2009 The MathWorks, Inc.

% Error checking
error(nargchk(1,3,nargin,'struct'));


if isfixed(x)

    nt_x = numerictype(x);
    wl_x = nt_x.WordLength;

    if nargin == 1
        left_idx = nt_x.WordLength;
        right_idx = 1;
    elseif nargin == 2
        right_idx = 1;
    end

    if (~isscalar(left_idx) || ~isscalar(right_idx))        
        error('fi:bitsliceget:invalidindex',...
            'bitsliceget indices must be scalar');
    end
    
    if (left_idx > wl_x || right_idx > left_idx || right_idx <= 0 )
        error('fi:bitsliceget:invalidindex',...
            'In bitsliceget the WordLength <= Left Index <= Right Index <= 1');
    end

    % Determine the output numerictype & fimath
    % Output numerictype is unsigned, WL = left_idx-right_idx + 1 & FL = 0
    nt_y = numerictype(0,left_idx-right_idx + 1,0);
    fm_y = fimath(x);

    if isempty(x)
        y = fi(zeros(size(x)),nt_y,fm_y);
    else
        % Now get the bit slice
        x1 = reshape(x,numberofelements(x),1);
        x1_bin = bin(x1);

        % index into bits (get lsb from right)
        y_bin = x1_bin(:,wl_x-left_idx+1:wl_x-right_idx+1);

        % Now create y
        y = fi(0,nt_y,fm_y); y.bin = y_bin;
        y = reshape(y,size(x));
    end
    y.fimathislocal = isfimathlocal(x);
else

    % non fi-fixedpoint not supported
    dt = x.dataType;
    fn = mfilename;
    errmsgid = sprintf('fixedpoint:fi:%s:%s:notallowed', fn,dt);
    error(errmsgid, 'Function ''%s'' is not defined for FI objects of data type ''%s''',fn,dt);

end
