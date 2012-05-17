%#eml
function eml_check_div_fimath(fm)
% check fimath is valid

%   Copyright 2006-2009 The MathWorks, Inc.

eml_allow_mx_inputs;
ishdltarget = strcmp(eml.target(), 'hdl');
if ~ishdltarget
    return;
end

rF = strcmp(fm.RoundMode, 'fix');
rN = strcmp(fm.RoundMode, 'nearest');

if ~(rF || rN)
    eml_assert(0, 'HDL code generation for fixed point division is only supported when ''RoundMode'' is ''Fix'' or ''Nearest''');
end

