function c = getlsb(a)
% Embedded MATLAB Library function.
%
% GETLSB Get a value of bit at LSB position
%
%    C = GETLSB(a)
%
%    C is of type ufix1 and has the same fimath of 'a'
%
%    A: must be a fi object matrix, array, or a scalar fi object
%    (signed or unsigned)
%
% The following cases will not be handled by this function:
%    a is not a fi object

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.5 $ $Date: 2009/03/05 18:47:03 $

if isfixed(a)
    
    Fm = eml_fimath(a);

    lidx = 1;
    ridx = 1;

    eml_bitop_index_checks('getlsb', a,lidx,ridx);

    eml_must_inline;

    % outtype is always unsigned, size is same as slice length and no scaling
    slice_nt = numerictype(false, 1, 0);

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
    eml_fi_assert_dataTypeNotSupported('GETLSB','fixed-point');
end
