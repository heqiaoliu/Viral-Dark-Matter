function y = bitconcat(u,v,varargin)
% BITCONCAT Combine stored integer bits of fixed point words
%
% SYNTAX
%   Y = BITCONCAT(A, B)
%   Y = BITCONCAT([A, B, C])
%   Y = BITCONCAT(A, B, C, D, ...)
%
% DESCRIPTION:
%   Y = BITCONCAT(A, B) returns a new fixed value with a concatenated bit
%       representation of input operands 'A' and 'B'.
%
%   1)	Output type is always unsigned with wordlength equal to sum of
%       input fixed point word lengths.
%   2)	Scaling has no bearing on the result type and value.
%   3)	The two's complement representation of inputs are concatenated to
%       form the stored integer value of the output.
%   4)	Mix and match of signed and unsigned inputs are allowed. Signed bit
%       is treated like any other bit.
%   5)	Input operands 'A' and 'B' can be vectors but should be of same
%       size. If the operands are vectors then concatenation will be
%       performed element-wise.
%   6)  complex inputs are not supported.
%   7)  Accepts varargin number of inputs for concatenation
%
%  See also EMBEDDED.FI/BITSLICEGET, EMBEDDED.FI/BITGET, EMBEDDED.FI/BITSET,
%           EMBEDDED.FI/BITAND, EMBEDDED.FI/BITOR, EMBEDDED.FI/BITXOR
%           EMBEDDED.FI/BITANDREDUCE, EMBEDDED.FI/BITORREDUCE,
%           EMBEDDED.FI/BITXORREDUCE
%

%   Copyright 2007-2009 The MathWorks, Inc.

if (nargin == 0)
    error('fi:bitconcat:invalidargs',...
        'bitconcat expects one or two fixed point input arguments');
end
    
if (nargin == 1)
    y = bitconcat_unary(u);
elseif (nargin == 2)
    y = bitconcat_binary(u, v);
else
    t = bitconcat_binary(u, v);
    for ii=1:nargin-2
        t = bitconcat_binary(t, varargin{ii});
    end
    y = t;
end


function y = bitconcat_unary(u)

bin_u = bin(reshape(u,u.numberofelements,1));
bin_u2 = reshape(bin_u',1,numel(bin_u));

nt_u = numerictype(u);
outwlen = length(u)*nt_u.WordLength;
nt_y = numerictype(0,outwlen,0);
if isempty(u)
    y = fi(zeros(size(u)), nt_y, fimath(u));
else
    y = fi(0, nt_y, fimath(u));
    y.bin = bin_u2;
end
y.fimathislocal = isfimathlocal(u);

function y = bitconcat_binary(u, v)

if isfixed(u) || isfixed(v)

    %error(nargchk(2,2,nargin,'struct'));

    if ~(isfi(u) && isfi(v))
        error('fi:bitconcat:invalidargs',...
            'invalid bitconcat input arguments');
    end

    nt_u = numerictype(u);
    wl_u = nt_u.WordLength;

    nt_v = numerictype(v);
    wl_v = nt_v.WordLength;

    % Determine the output numerictype
    nt_y = numerictype(0, wl_u + wl_v, 0);

    % output fimath is same as input u
    fm_y = fimath(u);


    bin_u = bin(reshape(u,u.numberofelements,1));
    bin_v = bin(reshape(v,v.numberofelements,1));

    % do scalar expansion and also find final size
    final_size = size(u);
    if isempty(u)&&isempty(v)
        % Both u and v are empty
        if ~isequal(size(u), size(v))
            error('fi:bitconcat:invalidargsizes',...
                'input arguments must have the same size or scalar');
        else
            y = fi(zeros(final_size),nt_y,fm_y);
        end
    else
        if (isempty(u)||isempty(v))
            error('fi:bitconcat:invalidargsizes',...
                'input arguments must have the same size or scalar');
            
        else
            % both u and v are non-empty
            if isscalar(u)
                final_size = size(v);
                bin_u = repmat(bin_u, v.numberofelements, 1);
            elseif isscalar(v)
                final_size = size(u);
                bin_v = repmat(bin_v, u.numberofelements, 1);
            elseif ~isequal(size(u), size(v))
                error('fi:bitconcat:invalidargsizes',...
                    'input arguments must have the same size or scalar');
            end

            bin_y = [bin_u, bin_v];
        end

        y_temp = fi(zeros(length(bin_y)),nt_y,fm_y);
        y_temp.bin = bin_y;

        y = reshape(y_temp, final_size);
    end
    y.fimathislocal = isfimathlocal(u);

else

    % non fi-fixedpoint not supported
    dt = u.dataType;
    fn = mfilename;
    errmsgid = sprintf('fixedpoint:fi:%s:%s:notallowed', fn,dt);
    error(errmsgid, 'Function ''%s'' is not defined for FI objects of data type ''%s''',fn,dt);

end
