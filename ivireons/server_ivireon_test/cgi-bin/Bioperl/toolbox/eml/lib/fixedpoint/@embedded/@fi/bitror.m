function cout = bitror(ain,kin)
% Embedded MATLAB Library function.
%
% BITROR bitwise rotate right
%

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.10 $  $Date: 2009/03/05 18:46:53 $

fnname = 'ror';

% To make sure the number of the input arguments is right
eml_assert(nargin == 2, 'No method ''ror'' with matching signature found for class ''embedded.fi''.');

if eml_ambiguous_types
    if isscalar(ain)
        cout = eml_not_const(reshape(zeros(size(kin)),size(kin)));
    else
        cout = eml_not_const(reshape(zeros(size(ain)),size(ain)));
    end
    return;
end

eml_lib_assert(~isempty(ain),'fixedpoint:fi:inputMustBeNonEmpty', ['empty input is not allowed in ''' fnname '']);
eml_assert(~isempty(kin), ['empty input is not allowed in ''' fnname '']);

eml_assert(isfi(ain), 'first operand to ''ror'' must be a fi object.');
eml_assert(isreal(kin), 'rotate index operand must be real.');
eml_assert(~isfi(kin), 'rotate index operand must be real.');
eml_assert(isscalar(kin), 'rotate index must be scalar.');
eml_assert(~eml_isslopebiasscaled(ain), 'bitror does not support slope-bias scaled fis.');

eml_prefer_const(kin);
if (eml_is_const(kin))
    eml_assert(kin >= 0, 'rotate index must be greater than or equal to zero');
end

aNT = numerictype(ain);
eml_assert(aNT.WordLength > 1, 'bitror not supported for 1-bit input operand');

if isfixed(ain)

    aFM = fimath(ain);   
        
    % set rnd,sat modes to trivial modes
    a = fi(ain, 'overflowmode', 'wrap', 'roundmode', 'floor');
    
    % First decide the output size & complexity
    ctemp = fi(zeros(size(a)),aNT,fimath(a));
    if ~isreal(a)
        c = complex(ctemp,ctemp);
    else
        c = ctemp;
    end

    % Inline the generated code if a is a scalar
    if isscalar(a)
        eml_must_inline;
    end

    % Do the bitshift
    k = uint8(kin);
    for m = 1:numel(a)
        % real
        cr = eml_bit_ror(real(a(m)),uint8(k));

        % if a is complex
        if ~isreal(a)
            ci = eml_bit_ror(imag(a(m)),uint8(k));
            c(m) = complex(cr,ci);
        else
            c(m) = cr;
        end
    end

    % restore rnd,sat modes or return a fimath-less fi
    if eml_const(eml_fimathislocal(ain))
        cout = fi(c, 'overflowmode', aFM.OverflowMode, 'roundmode', aFM.RoundMode);
    else
        cout = eml_fimathislocal(c,false);
    end
else
    % non fi-fixedpoint not supported
    eml_fi_assert_dataTypeNotSupported('BITROR','fixed-point');
end
