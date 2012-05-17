function [num, rat, loc] = biterr(varargin)
%BITERR Compute number of bit errors and bit error rate.
%   [NUMBER,RATIO] = BITERR(X,Y) compares the unsigned binary representation of
%   the elements in the two matrices X and Y.  X and Y must be logical or
%   integer valued. The number of differences in the binary representation is
%   output in NUMBER.  The ratio of NUMBER to the total number of bits used in
%   the binary representation is output in RATIO. The same number of bits is
%   used to represent each element in both X and Y. The number of bits used is
%   the smallest number required to represent the largest element in either X or
%   Y.  When one of the inputs is a matrix and the other is a vector the
%   function performs either a column-wise or row-wise comparison based on the
%   orientation of the vector.
%
%   Column : When one of the inputs is a matrix and the other is a column
%   Wise     vector with as many elements as there are rows in the input
%            matrix, a column-wise comparison is performed.  In this mode
%            the binary representation of the input column vector is
%            compared with the binary representation of each column of the
%            input matrix. By default the results of each column comparison
%            are output and both NUMBER and RATIO are row vectors. To
%            override this default and output the overall results, use the
%            'overall' flag(see below).
%   Row    : When one of the inputs is a matrix and the other is a row vector
%   Wise     with as many elements as there are columns in the input matrix, a
%            row-wise comparison is performed.  In this mode the binary
%            representation of the input row vector is compared with the
%            binary representation of each row of the input matrix.  By
%            default the results of each row comparison are output and both
%            NUMBER and RATIO are column vectors.  To override this default
%            and output the overall NUMBER and RATIO, use the 'overall'
%            flag(see below).
%
%   In addition to the two matrices, two optional parameters can be given:
%
%   [NUMBER,RATIO] = BITERR(...,K) The number of bits used to represent
%   each element is given by K.  K must be a positive scalar integer no
%   smaller than the minimum number of bits required to represent the
%   largest element in both input matrices.
%
%   [NUMBER,RATIO] = BITERR(...,CFLAG) uses CFLAG to specify how to perform
%   and report the comparison.  CFLAG has three possible values:
%   'column-wise', 'row-wise' and 'overall'.  If CFLAG is 'column-wise'
%   then BITERR compares each individual column and outputs the results as
%   row vectors. If CFLAG is 'row-wise' then BITERR compares each
%   individual row and outputs the results as column vectors.  Lastly, if
%   CFLAG is 'overall' then BITERR compares all elements together and
%   outputs the results as scalars.
%
%   [NUMBER,RATIO,INDIVIDUAL] = BITERR(...) outputs a matrix representing
%   the results of each individual binary comparison in INDIVIDUAL.  If two
%   elements are identical then the corresponding element in INDIVIDUAL is
%   zero.  If the two elements are different then the corresponding element
%   in INDIVIDUAL is the number of binary differences.  INDIVIDUAL is
%   always a matrix, regardless of mode.
%
%   Examples:
%       A = [1 2 3; 1 2 2];
%       B = [1 2 0; 3 2 2];
%
%       [Num1,Rat1] = biterr(A,B)        
%       [Num2,Rat2] = biterr(A,B,3)
%       [Num3,Rat3,Ind] = biterr(A,B,3,'column-wise')
%  
%   See also SYMERR.

%   Copyright 1996-2009 The MathWorks, Inc.
%   $Revision: 1.15.4.8 $  $Date: 2009/09/23 13:57:04 $

% --- Typical error checking.
error(nargchk(2,4,nargin,'struct'));

% --- Placeholder for the signature string.
sigStr = '';
flag = '';
K = [];

% --- Identify string and numeric arguments
for n=1:nargin
    if(n>1)
        sigStr(size(sigStr,2)+1) = '/';
    end
    % --- Assign the string and numeric flags
    if(ischar(varargin{n}))
        sigStr(size(sigStr,2)+1) = 's';
    elseif(isnumeric(varargin{n}) || islogical(varargin{n}))
        sigStr(size(sigStr,2)+1) = 'n';
    else
        error('comm:biterr:InvalidFlag','Only string and numeric arguments are accepted.');
    end
end

% --- Identify parameter signitures and assign values to variables
switch sigStr
    % --- biterr(a, b)
    case 'n/n'
        a		= varargin{1};
        b		= varargin{2};

        % --- biterr(a, b, K)
    case 'n/n/n'
        a		= varargin{1};
        b		= varargin{2};
        K		= varargin{3};


        % --- biterr(a, b, flag)
    case 'n/n/s'
        a		= varargin{1};
        b		= varargin{2};
        flag	= varargin{3};

        % --- biterr(a, b, K, flag)
    case 'n/n/n/s'
        a		= varargin{1};
        b		= varargin{2};
        K		= varargin{3};
        flag	= varargin{4};

        % --- biterr(a, b, flag, K)
    case 'n/n/s/n'
        a		= varargin{1};
        b		= varargin{2};
        flag	= varargin{3};
        K		= varargin{4};

        % --- If the parameter list does not match one of these signatures.
    otherwise
        error('comm:biterr:InvalidArgsPassed','Syntax error.');
end

if (isempty(a)) || (isempty(b))
    error('comm:biterr:NoInputs','Required parameter empty.');
end

validateattributes(a, {'numeric', 'logical'}, ...
    {'nonnan', 'finite', 'real', 'nonnegative', 'integer'}, 'BITERR', 'X', 1)
aIsNumeric = isnumeric(a);
validateattributes(b, {'numeric', 'logical'}, ...
    {'nonnan', 'finite', 'real', 'nonnegative', 'integer'}, 'BITERR', 'Y', 2)
bIsNumeric = isnumeric(b);

% Determine the sizes of the input matrices.
[am, an] = size(a);
[bm, bn] = size(b);

% If one of the inputs is a vector, it can be either the first or second input.
% This conditional swap ensures that the first input is the matrix and the second is the vector.
if ((am == 1) && (bm > 1)) || ((an == 1) && (bn > 1))
    [a, b] = deal(b, a);
    [am, an] = size(a);
    [bm, bn] = size(b);
end

% Check the sizes of the inputs to determine the default mode of operation.
if ((bm == 1) && (am > 1))
    default_mode = 'row-wise';
    if (an ~= bn)
        error('comm:biterr:MismatchedInputDims','Input row vector must contain as many elements as there are columns in the input matrix.');
    end
elseif ((bn == 1) && (an > 1))
    default_mode = 'column-wise';
    if (am ~= bm)
        error('comm:biterr:MismatchedInputDims','Input column vector must contain as many elements as there are rows in the input matrix.');
    end
else
    default_mode = 'overall';
    if (am ~= bm) || (an ~= bn)
        error('comm:biterr:MismatchedInputDims','Input matrices must be the same size.');
    end
end

% Check that the user specified mode of operation is valid.
if isempty(flag)
    flag = default_mode;
elseif ~(strcmp(flag,'column-wise') || strcmp(flag,'row-wise') || strcmp(flag,'overall'))
    error('comm:biterr:InvalidFlag','Invalid string flag.');
elseif strcmp(default_mode,'row-wise') && strcmp(flag,'column-wise')
    error('comm:biterr:ColFlagRowInput','A column-wise comparison is not possible with a row vector input.');
elseif strcmp(default_mode,'column-wise') && strcmp(flag,'row-wise')
    error('comm:biterr:RowFlagColInput','A row-wise comparison is not possible with a column vector input.');
end

% Determine the minimum number of bits needed to represent the matrices.
tmp = double(max( max(max(a)), max(max(b)) ));
if (tmp > 0)
    num_bits = floor(log2(tmp)) + 1;
else
    num_bits = 1;
end

if ~(aIsNumeric && bIsNumeric)
    if num_bits > 1
        error('comm:biterr:NonBinaryWithLogical',...
            'When one of the inputs is logical, the other input must be binary valued.');
    end
    if ~isempty(K) && any(K ~= 1)
        error('comm:biterr:InvalidNumBitsWithLogical',...
            'When one of the inputs is logical, number of bits, K, must be 1.');
    end
end

% Check that the user specified 'symbol length' is valid.
if ~isempty(K)
    if max(size(K)) > 1
        error('comm:biterr:NonScalarWordLength','Word length must be a scalar.');
    elseif (~isfinite(K)) || (floor(K)~=K) || (~isreal(K))
        error('comm:biterr:InvalidWordLength','Word length must be a finite, real integer.');
    elseif K < num_bits
        error('comm:biterr:ShortWordLength','The specified word length is too short for the matrix elements.');
    else
        num_bits = K;
    end
end

if aIsNumeric
    a2 = toBinary(a, num_bits);
else
    a2 = a;
end
if bIsNumeric
    b2 = toBinary(b, num_bits);
else
    b2 = b;
end

% Two separate flags are needed for the function to operate efficiently.
% 'default_mode' specifies if one of the inputs is actually a vector while
% the other is a matrix, meaning that the vector should be compared with each
% individual row or column of the matrix.  'flag' (which the user specifies)
% specifies how the results of this comparison are reported.

if strcmp(default_mode,'overall')
    num = zeros(1,an);
    if strcmp(flag,'column-wise')
        for i = 1:an
            num(1,i) = sum(sum(a2(:,((i-1)*num_bits+1):(i*num_bits)) ~= b2(:,((i-1)*num_bits+1):(i*num_bits))));
        end
        rat = num / (am*num_bits);
    elseif strcmp(flag,'row-wise')
        num = sum(a2~=b2,2);
        rat = num / (an*num_bits);
    else
        num = sum(sum(a2~=b2));
        rat = num / (am*an*num_bits);
    end
    if (nargout > 2)
        loc = zeros(am,an);
        for i = 1:an
            loc(:,i) = sum( (a2(:,((i-1)*num_bits+1):(i*num_bits)) ~= b2(:,((i-1)*num_bits+1):(i*num_bits))), 2);
        end
    end
elseif strcmp(default_mode,'column-wise')
    num = zeros(1,an);
    if (nargout < 3)
        for i = 1:an,
            num(1,i) = sum(sum(a2(:,((i-1)*num_bits+1):(i*num_bits))~=b2));
        end
    else
        loc = zeros(am,an);
        for i = 1:an,
            loc(:,i) = sum((a2(:,((i-1)*num_bits+1):(i*num_bits)) ~= b2), 2);
            num(1,i) = sum(loc(:,i));
        end
    end
    if strcmp(flag,'overall')
        num = sum(num);
        rat = num / (am*an*num_bits);
    else
        rat = num / (am*num_bits);
    end
else
    num = zeros(am,1);
    if (nargout < 3)
        for i = 1:am,
            num(i,1) = sum(a2(i,:)~=b2);
        end
    else
        loc = zeros(am,an);
        for i = 1:an
            for j = 1:am
                loc(j,i) = sum( (a2(j,((i-1)*num_bits+1):(i*num_bits)) ~= b2(1,((i-1)*num_bits+1):(i*num_bits))), 2);
            end
        end
        num(:,1) = sum(loc,2);
    end
    if strcmp(flag,'overall')
        num = sum(num);
        rat = num / (am*an*num_bits);
    else
        rat = num / (an*num_bits);
    end
end

%%%
function b = toBinary(a, num_bits)
% Convert matrix to binary representation

[am an] = size(a);
b = de2bi(a(:), num_bits);

% block transpose
b = reshape(permute(reshape(b', num_bits, am, an), [2 1 3]), am, num_bits*an);

% [EOF] biterr.m
