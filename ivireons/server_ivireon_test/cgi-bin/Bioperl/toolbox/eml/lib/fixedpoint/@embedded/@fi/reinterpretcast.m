function c = reinterpretcast(a,new_nt)
% Embedded MATLAB Library function.
%

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.5 $ $Date: 2009/10/24 19:03:34 $

eml_assert(nargin == 2, 'reinterpretcast: invalid number of arguments');
eml_assert(isfi(a), 'reinterpretcast: first input must be fi');
eml_assert(isnumerictype(new_nt), ...
           'The second argument to REINTERPRETCAST must be a NUMERICTYPE object.');

eml_assert(isfixed(a) && isfixed(new_nt), ...
           'The REINTERPRETCAST function only supports integer, fixed-point, or scaled double inputs.');
% fixedpoint:fi:reinterpretcast:onlyfixedpointnumerictype

eml_assert(~eml_isslopebiasscaled(a) && new_nt.SlopeAdjustmentFactor==1 && new_nt.Bias==0, ...
    'REINTERPRETCAST is only supported for operands that have an integer power of 2 slope, and a bias of 0.');
% fixedpoint:fi:onlybinarypointmath


nt_a = numerictype(a);
eml_assert(nt_a.WordLength == new_nt.WordLength, ...
    'The word length of the numeric type must be equal to the word length of the fi object being cast.');
% fixedpoint:fi:reinterpretcast:wrongwordlength

eml_assert(~strcmp(new_nt.scaling,'Unspecified'), ...
           'REINTERPRETCAST(A,T) is not supported when numerictype T has unspecified scaling.');
% fixedpoint:fi:reinterpretcast:unspecifiedscaling

eml_assert(~strcmp(new_nt.Signedness,'Auto'), ...
           'REINTERPRETCAST(A,T) is only supported when the SIGNEDNESS of NUMERICTYPE object T is SIGNED or UNSIGNED.');


% We have already asserted that A and new_nt are fixed-point.
if isreal(a)
    c = eml_fimathislocal(eml_reinterpretcast(a, new_nt), eml_fimathislocal(a));
else
    cr = eml_reinterpretcast(real(a), new_nt);
    ci = eml_reinterpretcast(imag(a), new_nt);
    c = eml_fimathislocal(complex(cr,ci), eml_fimathislocal(a));
end

