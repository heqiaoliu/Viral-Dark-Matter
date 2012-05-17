function eml_assert_all_constant(varargin)
%Embedded MATLAB Library Function

%EML_ASSERT_CONSTANT Throw assertion if any input is not const.
%    EML_ASSERT_CONSTANT(A,B,C, ...) will throw an assertion if any
%    input A, B, C, ... is not const.

% Copyright 2008 The MathWorks, Inc.
%#eml    
eml_transient;
for k = eml.unroll(1:nargin)
        eml_lib_assert(eml_is_const(varargin{k}),...
                       'EmbeddedMATLAB:AllConstInputs',...
                       'All inputs must be constant.');
end
