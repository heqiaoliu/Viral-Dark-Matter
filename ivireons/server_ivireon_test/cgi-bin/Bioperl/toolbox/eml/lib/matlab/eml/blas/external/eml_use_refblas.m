function p = eml_use_refblas
%Embedded MATLAB Private Function

%   Returns TRUE if the internal reference BLAS should be used.

%   Copyright 2007-2008 The MathWorks, Inc.
%#eml

eml_heisenfun;

p = (eml_is_constant_folding || ...
     eml_ambiguous_types || ...
     strcmp(eml.target(),'hdl'));
