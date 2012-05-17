function [h,info,z] = eml_xhseqr(h,z)
%Embedded MATLAB Private Function

%   Copyright 2010 The MathWorks, Inc.
%#eml

eml_must_inline;
if nargout == 3
    [h,info,z] = eml_lapack_xhseqr(h,z);
else
    [h,info] = eml_lapack_xhseqr(h);
end
