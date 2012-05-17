function [info,alpha1,beta1,V] = eml_xgeev(A)
%Embedded MATLAB Private Function

%   Copyright 2005-2010 The MathWorks, Inc.
%#eml

eml_must_inline;
if nargout == 4
    [info,alpha1,beta1,V] = eml_lapack_xgeev(A);
else
    [info,alpha1,beta1] = eml_lapack_xgeev(A);
end
