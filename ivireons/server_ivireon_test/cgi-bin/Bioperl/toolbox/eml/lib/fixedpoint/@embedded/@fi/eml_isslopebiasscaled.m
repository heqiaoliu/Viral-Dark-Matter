%#eml
function y = eml_isslopebiasscaled(x)
%     
    
eml_transient;
Tx = eml_typeof(x);
bias = get(Tx,'Bias');
saf = get(Tx,'SlopeAdjustmentFactor');
y = (bias~=0.0 || saf~=1.0); 
