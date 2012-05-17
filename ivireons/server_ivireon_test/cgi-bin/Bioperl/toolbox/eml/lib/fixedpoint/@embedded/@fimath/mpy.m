function c = mpy(f,a0,b0)
% Embedded MATLAB add function for fixed-point inputs

% Copyright 2002-2009 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2009/12/28 04:11:04 $
%#eml
    
eml.extrinsic('emlGetNTypeForTimes');
eml.extrinsic('eml_fi_math_with_same_types');
eml_allow_mx_inputs;
eml_assert(nargin==3,'Incorrect number of input arguments.');

eml_lib_assert(((isscalar(a0))||(isscalar(b0))||(isequal(size(a0),size(b0)))), 'fixedpoint:fi:dimagree', 'Matrix dimensions must agree.')
% Check for ambiguous types and return with the correct size output
if eml_ambiguous_types
    numelA = prod(size(a0)); numelB = prod(size(b0)); %#ok
    isrealC = isreal(a0) && isreal(b0);
    if numelA > numelB
        ctemp = eml_not_const(zeros(size(a0)));
    else
        ctemp = eml_not_const(zeros(size(b0)));
    end
    if isrealC
        c = ctemp;
    else
        c = complex(ctemp,ctemp);
    end
    return;
end
    
% Checking for input (types) here: should be fi,fi
if (~isfi(a0) || ~isfi(b0))
    eml_assert(0,'No method ''mpy'' with matching signature found for class ''embedded.fimath''.');
end

% Verify that the datatypes are the same
% - Scaled-type with floating not allowed
% - Single with Double not allowed
ta = eml_typeof(a0); tb = eml_typeof(b0);
[ERR,a2SD,b2SD,Tsd] = eml_const(eml_fi_math_with_same_types(ta,tb));
eml_assert(isempty(ERR),ERR);    
 
if isfixed(a0) || isfixed(b0)
    % Check if a or b have to cast into scaled-doubles
    if a2SD
        a = eml_cast(a0,Tsd,fa);
    elseif b2SD
        b = eml_cast(b0,Tsd,fb);
    else
        a = a0; b = b0;
    end
    
    % Check for the SlopeBias mode, complex inputs are not supported in this case
    biasA     = eml_const(get(ta,'Bias'));
    biasB     = eml_const(get(tb,'Bias'));
    non_zero_Bias = (biasA~=0)||(biasB~=0);
    
    safA      = eml_const(get(ta,'SlopeAdjustmentFactor'));
    safB      = eml_const(get(tb,'SlopeAdjustmentFactor'));
    non_trivial_SAF = (safA~=1)||(safB~=1);
    
    isslopebias_in = non_zero_Bias||non_trivial_SAF;
    iscomplex_in   = ~isreal(a0) || ~isreal(b0);
    
    eml_assert((isslopebias_in&&iscomplex_in)==0,...
               'Function ''times'' is not defined for complex-value FI objects with slope and bias scaling.');
    
    % Get the product type tp & final result type tc
    aIsReal = isreal(a); bIsReal = isreal(b);
    maxWL = eml_option('FixedPointWidthLimit');
    [tp,errmsg1] = eml_const(emlGetNTypeForTimes(ta,tb,f,true,true,maxWL));
    if ~isempty(errmsg1)
        eml_assert(0,errmsg1);
    end

    [tc,errmsg2] = eml_const(emlGetNTypeForTimes(ta,tb,f,aIsReal,bIsReal,maxWL));
    if ~isempty(errmsg2)
        eml_assert(0,errmsg2);
    end
    
    c = eml_fimathislocal(eml_fixpt_times(eml_cast(a,ta,f),eml_cast(b,tb,f),tc,tp,f),false);
     
elseif ( isfloat(a0) || isfloat(b0))
    % True Double or True Single FI
    % call ML plus directly
    check4constNonFI   = false; % non-FI need not be constant
    check4numericData  = true;  % non-FI must be numeric
    check4sameDatatype = true;  % The datatypes of two inputs must be same

    [ain,bin] = eml_fi_cast_two_inputs(a0,b0,'.*',check4constNonFI,...
                                       check4numericData,check4sameDatatype);
    t = eml_fi_get_numerictype_fimath(a0,b0);
    
    c = eml_fimathislocal(eml_times(ain,bin,t,f),false);
else
    eml_fi_assert_dataTypeNotSupported('PLUS','fixed-point,double, or single');
end
