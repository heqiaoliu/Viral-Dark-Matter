function c = bitandreduce(a,lidx,ridx)
% Embedded MATLAB Library function.
%
% BITANDREDUCE Perform bitwise-and reduction on a range of bits in a fixed point word.
%
%    C = BITANDREDUCE(A,LIDX, RIDX) returns a bit after perform bitwise or
%        on all the indvidual bits in the range LIDX and RIDX
%
%    The return type is ufix1
%
%    A must be a fi object matrix, array, or a scalar fi object
%    (signed or unsigned)
%
%    ridx must be an integer corresponding to a bit position in A
%
%    lidx: must be an integer corresponding to a bit position in A
%
%    left index must be greater than equal to right index and less than
%    equal to word length of input operand a
%


%   Copyright 2002-2009 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.8 $ $Date: 2009/11/13 04:16:44 $

% To make sure the number of the input arguments is right


if eml_ambiguous_types
    c = eml_not_const(reshape(zeros(size(a)),size(a)));
    return;
end

if (nargin > 1)
    eml_assert(~isempty(lidx), 'empty input is not allowed in ''bitandreduce''');
    eml_assert(isnumeric(lidx), 'left index must be numeric in ''bitandreduce''');
end
if (nargin > 2)
    eml_assert(~isempty(ridx), 'empty input is not allowed in ''bitandreduce''');
    eml_assert(isnumeric(ridx), 'right index must be numeric in ''bitandreduce''');
end

if isfixed(a)
    
    Ta = eml_typeof(a);
    Fm = eml_fimath(a);

    if nargin == 1
        lidx = Ta.WordLength;
        ridx = 1;
    elseif nargin == 2
        ridx = ones(1, class(lidx));
    end

    eml_bitop_index_checks('bitandreduce', a,lidx,ridx)

    eml_must_inline;

    ufix1 = numerictype(0, 1, 0);
    
    
    % If a has an attached fimath, then c will also have one
    % Otherwise c is a fimath-less fi
    if eml_const(eml_fimathislocal(a))
        c = fi(zeros(size(a)), 'numerictype', ufix1, 'fimath', Fm);
    else
        c = fi(zeros(size(a)), 'numerictype', ufix1);
    end


    for k = 1:eml_numel(c)
        c(k) = eml_bitandreduce(a(k), eml_const(lidx-1), eml_const(ridx-1));
    end


else
    
    % non fi-fixedpoint not supported
    eml_fi_assert_dataTypeNotSupported('BITANDREDUCE','fixed-point');
    
end

