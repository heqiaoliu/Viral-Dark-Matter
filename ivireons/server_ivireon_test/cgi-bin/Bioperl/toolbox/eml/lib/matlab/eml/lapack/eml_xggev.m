function [info,alpha1,beta1,V] = eml_xggev(A,B)
%Embedded MATLAB Private Function

%   Copyright 2005-2010 The MathWorks, Inc.
%#eml

eml_must_inline;
if nargout == 4
    [info,alpha1,beta1,V] = eml_lapack_xggev(A,B);
else
    [info,alpha1,beta1] = eml_lapack_xggev(A,B);
end
