function eml_fi_checkforconst(varargin)
% EML_FI_CHECKFORCONST Private library function asserts that var2 to varN in fi(...) are constants

% Copyright 2005-2008 The MathWorks, Inc.
%#eml
    
% This eML library function allows and can handle mxArray inputs
eml_allow_mx_inputs;  

eml.extrinsic('num2str');
eml_prefer_const(varargin);

% Do not use "Input #d" here because #d is treated as hyperlink to a SF object by SF error manager.
for i = 1:numel(varargin)
    eml_assert(eml_is_const(varargin{i}),... 
              eml_const(['Inputs var2..varN in call to fi(var1, var2,..varN) must be constant. Input ', num2str(i), ' is not a constant']));
end;

