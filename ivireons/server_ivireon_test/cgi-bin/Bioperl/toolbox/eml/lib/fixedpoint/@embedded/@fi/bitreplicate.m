function c = bitreplicate(a,N)
% Embedded MATLAB Library function.
%
% CONCAT Perform concatenation of fixpt input operands N times.
%

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.5 $ $Date: 2009/12/28 04:10:50 $

if eml_ambiguous_types
    c = eml_not_const(reshape(zeros(size(a)),size(a)));
    return;
end

fnname = 'bitreplicate';

eml_assert(isfi(a), 'first input must be fixed point.');
eml_assert(isreal(N) && isscalar(N), 'second input must be real.');

eml_assert(~isempty(N), ['empty input is not allowed in ''' fnname '']);

eml_lib_assert(eml_scalexp_compatible(a,N), 'fixedpoint:fi:dimagree', 'Matrix dimensions must agree.');

eml_assert(isnumeric(N), ' input must be built-in numeric type');

eml_assert(eml_is_const(N), 'replication constant needs to be a constant');
eml_assert(N > 0, 'replication constant needs to be non-zero positive integer');

Ta = eml_typeof(a);
wlen = Ta.WordLength;

maxWL = eml_option('FixedPointWidthLimit');

if maxWL == 128
    msg_str = 'cannot replicate bits to more than 128 bits';
elseif maxWL == 32
    msg_str = 'cannot replicate bits to more than 32 bits';
else
    msg_str = 'cannot replicate bits to more than maximum number of bits';
end
eml_assert((eml_const(wlen*N) <= maxWL), msg_str);

if N == 1
  c = a;
else
  c = bitconcat(a,bitreplicate(a, N-1));
end


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function c = bitreplicate_unary(a, n)
% if n == 1
%     c = a;
% else
%     c = bitreplicate_unary2(a,1,n);
% end
% end
% 
% function c = bitreplicate_unary2(a,i,n)
% 
% if i == n
%     c = a;
% else
%     c = bitconcat(a,bitreplicate_unary2(a,i+1,n));
% end
% 
% end
