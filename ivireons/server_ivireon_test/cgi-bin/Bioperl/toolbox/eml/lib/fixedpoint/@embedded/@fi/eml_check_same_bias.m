%#eml
function eml_check_same_bias(a0, b0)
% Check that the bias values of the two fi's are equal

ta = eml_typeof(a0); 
tb = eml_typeof(b0);

biasA = eml_const(get(ta,'Bias')); 
biasB = eml_const(get(tb,'Bias'));

if biasA ~= biasB
    eml_assert(0,'Relational operator is not supported when bias values are unequal.');
end
