%#eml
function eml_check_fimath(fm)
% check fimath is valid

%   Copyright 2006-2008 The MathWorks, Inc.

eml_allow_mx_inputs;
ishdltarget = strcmp(eml.target(), 'hdl');
if ~ishdltarget
    return;
end

sum_mode = strcmp(fm.SumMode, 'SpecifyPrecision');
product_mode = strcmp(fm.ProductMode, 'SpecifyPrecision');
sat = strcmp(fm.OverflowMode, 'saturate');

if ((sum_mode || product_mode) && sat)
    eml_assert(0, 'HDL code generation is not supported for fixed-point arithmetic when the fimath ''OverflowMode'' is ''Saturate'' and the ''SumMode'' or ''ProductMode'' is set to ''SpecifyPrecision''.');
end

