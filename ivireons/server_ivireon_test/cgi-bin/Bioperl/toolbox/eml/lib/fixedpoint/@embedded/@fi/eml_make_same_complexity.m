%#eml
function [a1 b1] = eml_make_same_complexity(a0, b0)
% Make the complexity of two fi's the same

eml_allow_mx_inputs;

if isreal(a0) && ~isreal(b0)
    a1 = complex(a0,0);
    b1 = b0;
elseif ~isreal(a0) && isreal(b0)
    a1 = a0;
    b1 = complex(b0,0);
else
    a1 = a0;
    b1 = b0;
end    


