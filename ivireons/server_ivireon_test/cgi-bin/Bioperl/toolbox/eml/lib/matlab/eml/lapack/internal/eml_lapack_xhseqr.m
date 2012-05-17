function [h,info,z] = eml_lapack_xhseqr(h,z)
%Embedded MATLAB Private Function

%   Copyright 2010 The MathWorks, Inc.
%#eml

eml_must_inline;
if nargout == 3
    if isreal(h)
        [h,info,z] = eml_matlab_dhseqr(h,z);
    else
        [h,info,z] = eml_matlab_zhseqr(h,z);
    end
else
    if isreal(h)
        [h,info] = eml_matlab_dhseqr(h);
    else
        [h,info] = eml_matlab_zhseqr(h);
    end
end
