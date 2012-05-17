function y = bitandreduce(x,left_idx,right_idx)
% BITANDREDUCE Perform bitwise-and on a range of bits
%
% SYNTAX
%   C = BITANDREDUCE(A, LEFT_IDX, RIGHT_IDX)
%   C = BITANDREDUCE(A, LEFT_IDX)
%   C = BITANDREDUCE(A)
%
% DESCRIPTION:
%   C = BITANDREDUCE(A, LEFT_IDX, RIGHT_IDX) returns ufix1 after performing
%       a bitwise-and operation on consecutive set of bits starting
%       at RIGHT_IDX (close to LSB) and ending at LEFT_IDX (close to MSB).
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
%   9)	BITANDREDUCE does not support complex input types
%
%  See also EMBEDDED.FI/BITGET, EMBEDDED.FI/BITSET, EMBEDDED.FI/BITCONCAT,
%           EMBEDDED.FI/BITAND, EMBEDDED.FI/BITOR, EMBEDDED.FI/BITXOR
%           EMBEDDED.FI/BITORREDUCE,  EMBEDDED.FI/BITXORREDUCE
%

%   Copyright 2007-2009 The MathWorks, Inc.

% Error checking
error(nargchk(1,3,nargin,'struct'));



if isfixed(x)


    if ~isfi(x)
        error('fi:bitandreduce:invalidargs',...
            'invalid first argument to bitandreduce, must be fi');
    end

    nt_x = numerictype(x);
    wl_x = nt_x.WordLength;

    if nargin == 1
        left_idx = wl_x;
        right_idx = 1;
    elseif nargin == 2
        right_idx = 1;
    end

    if (~isnumeric(left_idx) || ~isnumeric(right_idx))
        error('fi:bitandreduce:invalidindex',....
            'bitandreduce indices must be numeric');
    end
        
    if (~isscalar(left_idx) || ~isscalar(right_idx))        
        error('fi:bitandreduce:invalidindex',...
            'bitandreduce indices must be scalar');
    end
    
    if (left_idx > wl_x || right_idx > left_idx || right_idx <= 0 )
        error('fi:bitandreduce:invalidindex',...
            'In bitandreduce the WordLength <= Left Index <= Right Index <= 1');
    end
    
    if isempty(x)
        
        y = fi(zeros(size(x)),numerictype(0,1,0),fimath(x));
        
    else
        
        yslice = bitsliceget(x, left_idx, right_idx);

        yslice_nt = numerictype(yslice);
        yslice_fm = fimath(yslice);

        yall_ones = bitcmp(fi(0, yslice_nt, yslice_fm));

        y_nt = numerictype(0,1,0);
        y_fm = fimath(x);

        y = fi(yslice == yall_ones, y_nt, y_fm);
        
    end

    y.fimathislocal = isfimathlocal(x);

else

    % non fi-fixedpoint not supported
    dt = x.dataType;
    fn = mfilename;
    errmsgid = sprintf('fixedpoint:fi:%s:%s:notallowed', fn,dt);
    error(errmsgid, 'Function ''%s'' is not defined for FI objects of data type ''%s''',fn,dt);

end
