function y = bitorreduce(x,left_idx,right_idx)
% BITORREDUCE Perform bitwise-or on a range of bits
%
% SYNTAX
%   C = BITORREDUCE(A, LEFT_IDX, RIGHT_IDX)
%   C = BITORREDUCE(A, LEFT_IDX)
%   C = BITORREDUCE(A)
%
% DESCRIPTION:
%   C = BITORREDUCE(A, LEFT_IDX, RIGHT_IDX) returns ufix1 after performing
%       a bitwise-or operation on consecutive set of bits starting
%       at right_idx (close to LSB) and ending at left_idx (close to MSB).
%
%   1)	Requires a fixed point input operand.
%   2)	if LEFT_IDX is not specified then LEFT_IDX defaults to wordlength(A)
%   3)	if RIGHT_IDX is not specified then RIGHT_IDX defaults to 1.
%   4)	Indices must satisfy the condition
%          wordlength(A)  >= LEFT_IDX >= RIGHT_IDX >= 1
%   5)	LEFT_IDX and RIGHT_IDX must be constants.
%   6)	Scaling has no bearing on the result type and value.
%   7)	Result type is always ufix1.
%   8)	Both signed and unsigned inputs with arbitrary scaling are allowed.
%       These properties have no bearing on result.
%       The operation is performed on 2's complement bit representation
%       of the stored integer.
%   9)	BITORREDUCE does not support complex input types
%
%  See also EMBEDDED.FI/BITGET, EMBEDDED.FI/BITSET, EMBEDDED.FI/BITCONCAT,
%           EMBEDDED.FI/BITAND, EMBEDDED.FI/BITOR, EMBEDDED.FI/BITXOR
%           EMBEDDED.FI/BITXORREDUCE,  EMBEDDED.FI/BITANDREDUCE
%

%   Copyright 2007-2009 The MathWorks, Inc.

% Error checking
error(nargchk(1,3,nargin,'struct'));


if isfixed(x)


    if ~isfi(x)
        error('fi:bitorreduce:invalidargs',...
            'invalid first argument to bitorreduce, must be fi');
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
        error('fi:bitorreduce:invalidindex',...
            'bitorreduce indices must be scalar');
    end
    
    if (left_idx > wl_x || right_idx > left_idx || right_idx <= 0 )
        error('fi:bitorreduce:invalidindex',...
            'In bitorreduce the WordLength <= Left Index <= Right Index <= 1');
    end

    if isempty(x)
        
        y = fi(zeros(size(x)),numerictype(0,1,0),fimath(x));
        
    else
        
        yslice = bitsliceget(x, left_idx, right_idx);

        y_nt = numerictype(0,1,0);
        y_fm = fimath(x);

        y = fi(yslice ~= 0, y_nt, y_fm);
    end

    y.fimathislocal = isfimathlocal(x);
else

    % non fi-fixedpoint not supported
    dt = x.dataType;
    fn = mfilename;
    errmsgid = sprintf('fixedpoint:fi:%s:%s:notallowed', fn,dt);
    error(errmsgid, 'Function ''%s'' is not defined for FI objects of data type ''%s''',fn,dt);

end
