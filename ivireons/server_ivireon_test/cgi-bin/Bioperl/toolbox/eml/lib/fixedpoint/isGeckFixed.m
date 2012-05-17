%#eml
function y = isGeckFixed(geckNum)
%ISGECKFIXED ISGECKFIXED is a function to be used for the EML 33+ fixed-point
%            tests. It is used to disable test-points till the relevant
%            geck(s) are fixed.
eml_transient;
eml.extrinsic('eml_isgeckfixed_helper');
y = eml_const(eml_isgeckfixed_helper(geckNum));
