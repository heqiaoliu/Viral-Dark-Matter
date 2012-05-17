function dim = eml_statop_validate_and_get_dim(x, isnumin1, dimx)%#eml
%EML_STATOP_VALIDATE_AND_GET_DIM Internal use only function
%   DIM = EML_STATOP_VALIDATE_AND_GET_DIM(X, ISNUMIN1, DIMX) returns the
%   first non-singleton dimension of X if ISNUMIN1 is true; otherwise it
%   verifies the validity of the dimension specified by DIM and returns the
%   same after casting to double.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2009/09/09 21:06:36 $
if isnumin1
    
    dim = eml_const_nonsingleton_dim(x);
    eml_lib_assert(eml_is_const(size(x)) || isscalar(x) || size(x, dim) ~= 1,...
        'EmbeddedMATLAB:mean:autoDimIncompatibility', ...
        ['The working dimension was selected automatically, is ', ...
        'variable-length, and has length 1 at run-time. This is not ', ...
        'supported. Manually select the working dimension by ', ...
        'supplying the DIM argument.']);
else
    
    eml_prefer_const(dimx);
    dim = eml_cast(dimx,'double');
    eml_assert(eml_is_const(dim), 'Dimension argument must be a constant.');
    eml_assert_valid_dim(dim);
end