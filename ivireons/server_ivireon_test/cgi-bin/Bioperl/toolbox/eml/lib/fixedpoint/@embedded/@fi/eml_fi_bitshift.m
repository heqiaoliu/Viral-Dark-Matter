function cout = eml_fi_bitshift(ain, kin, fnname)
% Embedded MATLAB Library function.
%
% EML_FI_BITSHIFT bit-wise shift
%

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.2 $  $Date: 2009/12/28 04:10:52 $

% A shift is a shift; This function ignores fimath, 
% does not generate saturation and rounding logic. 

% Common argument assertion checking and code generation optimizations
eml_assert(eml_is_const(fnname), 'eml_fi_bitshift invalid function name argument');
eml_lib_assert(~isempty(ain),'fixedpoint:fi:inputMustBeNonEmpty', ['empty input is not allowed in ''' fnname '']);
eml_assert(~isempty(kin), ['empty input is not allowed in ''' fnname '']);
eml_prefer_const(kin);
eml_shift_checks(fnname, ain, kin);
if eml_is_const(kin)
    eml_assert(kin >= 0, [fnname ' shift index cannot be negative']);    
    aNT = numerictype(ain);
    eml_assert(kin < eml_const(aNT.WordLength), [fnname ' shift index should be less than wordlength of input operand']);
end

if isscalar(ain)
    eml_must_inline;
end

if eml_ambiguous_types
    if isreal(ain)
        if isscalar(ain)
            cout = eml_not_const(reshape(zeros(size(kin)),size(kin)));
        else
            cout = eml_not_const(reshape(zeros(size(ain)),size(ain)));
        end
    else
        if isscalar(ain)
            cout = eml_not_const(reshape(complex(zeros(size(kin)),zeros(size(kin))),size(kin)));
        else
            cout = eml_not_const(reshape(complex(zeros(size(ain)),zeros(size(ain))),size(ain)));
        end
    end
elseif isfixed(ain)
    % --------------
    % FIXED-POINT FI
    % --------------
    if eml_const(strcmpi(fnname, 'bitsra'))
        aNT = numerictype(ain);
        eml_assert(eml_const(aNT.WordLength) > 1, ...
            'bitsra input operand word length must be greater than one');
    end
    
    switch(fnname)
        case 'bitsll'
            eml_shift_fnname = 'eml_lshift';
        case 'bitsra'
            eml_shift_fnname = 'eml_rshift';
        otherwise
            eml_shift_fnname = 'eml_rshift_logical';
    end

    % Set rnd,sat modes to trivial modes.
    a = fi(ain, 'overflowmode', 'wrap', 'roundmode', 'floor');
    
    % Need to do the bitshift using an integer shift value
    if isa(kin, 'integer')
        c = fixpt_bitshift_local(a, kin, eml_shift_fnname);
    elseif isfloat(kin)
        % Floating-point shift value
        if eml_is_const(kin)
            c = fixpt_bitshift_local(a, uint16(kin), eml_shift_fnname);
        else
            % VARIABLE floating-point shift value:
            % Use a FI temp var to avoid undesirable
            % range checking code e.g., from uint16(kin) cast
            c = fixpt_bitshift_local(a, ...
                int(fi(kin, 0, 16, 0, 'overflowmode', 'wrap', 'roundmode', 'floor')), ...
                eml_shift_fnname);
        end
    else
        % Fixed-point (non-builtin) shift value
        eml_assert(isfixed(kin), [fnname ' unsupported fixed-point shift value data type']);
        eml_assert(isequal(kin.FracionLength, 0), [fnname ' fixed-point shift value data type must have a fraction length of zero']);
        c = fixpt_bitshift_local(a, int(kin), eml_shift_fnname);
    end
    
    % Form return value with original fimath settings
    if eml_const(eml_fimathislocal(ain))
        cout = fi(c, 'fimath', fimath(ain)); % restore local fimath
    else
        cout = eml_fimathislocal(c, false); % return fimath-less fi
    end
elseif isfloat(ain)
    % -----------------
    % FLOATING-POINT FI
    % -----------------    
    % Using EML_LDEXP avoids extra generated saturation code.
    % Also, note that EML_LDEXP only handles REAL SCALAR inputs.
    cout = eml.nullcopy(ain);
    switch eml_const(fnname)
      case 'bitsll'
        kinInteger = int32(kin);
      case 'bitsra'
        kinInteger = -(int32(kin));
      otherwise
        % 'bitsrl' does not support FLOATING-POINT-FI types
        kinInteger = -(int32(kin));
        eml_fi_assert_dataTypeNotSupported(fnname,'fixed-point');
    end
    ainT = eml_typeof(ain);
    for idx = 1:numel(ain)
        if isreal(ain)
            % Real
            if eml_const(strcmpi(get(ainT, 'DataType'), 'Single'))
                cflt = eml_ldexp(single(ain), kinInteger);
            else
                cflt = eml_ldexp(double(ain), kinInteger);
            end
        else
            % Complex
            if eml_const(strcmpi(get(ainT, 'DataType'), 'Single'))
                coutReal  = eml_ldexp(single(real(ain(idx))), kinInteger);
                coutImag  = eml_ldexp(single(imag(ain(idx))), kinInteger);
            else
                coutReal  = eml_ldexp(double(real(ain(idx))), kinInteger);
                coutImag  = eml_ldexp(double(imag(ain(idx))), kinInteger);
            end
            cflt = complex(coutReal, coutImag);
        end
        cout(idx) = fi(cflt, numerictype(ain));
    end % for idx = 1:numel(ain)
else
    % Unsupported FI type
    eml_fi_assert_dataTypeNotSupported(fnname,'numeric');
end

% =========================================================================
function c = fixpt_bitshift_local(a, shift_val_int, eml_shift_fnname)

eml_prefer_const(shift_val_int);
eml_prefer_const(eml_shift_fnname);

if isscalar(a)
    if isreal(a)
        c = eml_feval(eml_shift_fnname, a, shift_val_int);
    else
        cr = eml_feval(eml_shift_fnname, real(a), shift_val_int);
        ci = eml_feval(eml_shift_fnname, imag(a), shift_val_int);
        c  = complex(cr,ci);
    end
else
    % Non-scalar (with indexing)
    c = eml.nullcopy(a);
    if isreal(a)
        for m = 1:numel(a)
            c(m) = eml_feval(eml_shift_fnname, a(m), shift_val_int);
        end
    else
        for m = 1:numel(a)
            cr   = eml_feval(eml_shift_fnname, real(a(m)), shift_val_int);
            ci   = eml_feval(eml_shift_fnname, imag(a(m)), shift_val_int);
            c(m) = complex(cr,ci);
        end
    end
end
