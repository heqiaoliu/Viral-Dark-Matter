function A = eml_zrot_rows(A,c,s,xrow,yrow,jlo,jhi)
%Embedded MATLAB Private Function

%   Plane rotation of A(xrow,jlo:jhi) and A(yrow,jlo:jhi)

%   Copyright 2005-2007 The MathWorks, Inc.
%#eml

eml_must_inline;
for j = jlo : jhi
    stemp = c*A(xrow,j) + s*A(yrow,j);
    A(yrow,j) = c*A(yrow,j) - eml_conjtimes(s,A(xrow,j));
    A(xrow,j) = stemp;
end
