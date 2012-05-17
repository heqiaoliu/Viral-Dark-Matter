function c = bitsliceget(a,lidx,ridx)
% Embedded MATLAB Library function.
%
% BITSLICEGET Get a range of bits in a fixed point word.
%
%    C = BITSLICEGET(A,LIDX, RIDX) returns the value of the bits at position 
%        starting at position ridx to lidx in the stored-integer of 
%        fi objects a.
%
%    C will always be unsigned with length
%
%    A: must be a fi object matrix, array, or a scalar fi object 
%    (signed or unsigned)
%
%    ridx: must be an integer corresponding to a bit position in A
%    lidx: must be an integer corresponding to a bit position in A
%
%    conditions: lidx > ridx
%       
% The following cases will not be handled by this function:
%    a is not a fi object

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.8 $ $Date: 2009/03/30 23:29:57 $

if eml_ambiguous_types
    c = eml_not_const(reshape(zeros(size(a)),size(a)));
    return;
end

if (nargin > 1)
    eml_assert(~isempty(lidx), 'empty input is not allowed in ''bitsliceget''');
end
if (nargin > 2)
    eml_assert(~isempty(ridx), 'empty input is not allowed in ''bitsliceget''');
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
    
    % do checks
    eml_bitop_index_checks('bitsliceget', a,lidx,ridx);

    eml_must_inline;

    % outtype is always unsigned, size is same as slice length and no scaling
    slice_nt = numerictype(false, eml_const(lidx - ridx + 1), 0);

    % If a has an attached fimath, then c will also have one
    % Otherwise c is a fimath-less fi
    if eml_const(eml_fimathislocal(a))
        c = fi(zeros(size(a)), 'numerictype', slice_nt, 'fimath', Fm);
    else
        c = fi(zeros(size(a)), 'numerictype', slice_nt);
    end


    for k = 1:eml_numel(c)
        c(k) = eml_bitslice(a(k), eml_const(lidx-1), eml_const(ridx-1));
    end

else
    
    % non fi-fixedpoint not supported
    eml_fi_assert_dataTypeNotSupported('BITSLICEGET','fixed-point');
end
