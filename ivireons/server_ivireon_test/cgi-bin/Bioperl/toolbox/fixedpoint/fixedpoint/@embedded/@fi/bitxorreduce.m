function y = bitxorreduce(x,left_idx,right_idx)
% BITXORREDUCE Perform bitwise-xor on a range of bits
%
% SYNTAX
%   c = bitxorreduce(a, left_idx, right_idx)
%   c = bitxorreduce(a, left_idx)
%   c = bitxorreduce(a)
%
% DESCRIPTION:
%   c = bitxorreduce(a, left_idx, right_idx) returns ufix1 after performing
%       a bitwise-xor operation on consecutive set of bits starting
%       at right_idx (close to LSB) and ending at left_idx (close to MSB).
%
%   1)	Requires a fixed point input operand.
%   2)	if left_idx is not specified then left_idx defaults to wordlength(a)
%   3)	if right_idx is not specified then right_idx defaults to 1.
%   4)	Indices must satisfy the condition
%          wordlength(a)  >= left_idx >= right_idx >= 1
%   5)	left_idx and right_idx must be constants.
%   6)	Scaling has no bearing on the result type and value.
%   7)	Result type is always ufix1.
%   8)	Both signed and unsigned inputs with arbitrary scaling are allowed.
%       These properties have no bearing on result.
%       The operation is performed on 2's complement bit representation
%       of the stored integer.
%   9)	bitxorreduce does not support complex input types
%
%  See also EMBEDDED.FI/BITGET, EMBEDDED.FI/BITSET, EMBEDDED.FI/BITCONCAT,
%           EMBEDDED.FI/BITAND, EMBEDDED.FI/BITOR, EMBEDDED.FI/BITXOR
%           EMBEDDED.FI/BITORREDUCE,  EMBEDDED.FI/BITANDREDUCE
%

%   Copyright 2007-2009 The MathWorks, Inc.

% Error checking
error(nargchk(1,3,nargin,'struct'));


if isfixed(x)


    if ~isfi(x)
        error('fi:bitxorreduce:invalidargs',...
            'invalid first argument to bitxorreduce, must be fi');
    end

    nt_x = numerictype(x);
    wl_x = nt_x.WordLength;

    if nargin == 1
        left_idx = wl_x;
        right_idx = 1;
    elseif nargin == 2
        right_idx = 1;
    end

    if (~isscalar(left_idx) || ~isscalar(right_idx))        
        error('fi:bitxorreduce:invalidindex',...
            'bitxorreduce indices must be scalar');
    end
    
    if (left_idx > wl_x || right_idx > left_idx || right_idx <= 0 )
        error('fi:bitxorreduce:invalidindex',...
            'In bitxorreduce the WordLength <= Left Index <= Right Index <= 1');
    end
    
    if isempty(x)
        
        y = fi(zeros(size(x)),numerictype(0,1,0),fimath(x));
        
    else

        yslice = bitsliceget(x, left_idx, right_idx);

        yt = reshape(yslice,numberofelements(yslice),1);
        yt_bin = yt.bin;

        yt1 = zeros(size(yt));

        for ii=1:length(yt)
            num_ones = strfind(yt_bin(ii,:), '1');
            if ~isempty(num_ones)
                num_ones = length(num_ones);
            else
                num_ones = 0;
            end

            yt1(ii) = mod(num_ones,2);
        end

        nt_yt = numerictype(0,1,0);
        fm_yt = fimath(yt);

        yt = fi(yt1, nt_yt, fm_yt);
        y = reshape(yt,size(x));
    end
    y.fimathislocal = isfimathlocal(x);

else

    % non fi-fixedpoint not supported
    dt = x.dataType;
    fn = mfilename;
    errmsgid = sprintf('fixedpoint:fi:%s:%s:notallowed', fn,dt);
    error(errmsgid, 'Function ''%s'' is not defined for FI objects of data type ''%s''',fn,dt);

end
