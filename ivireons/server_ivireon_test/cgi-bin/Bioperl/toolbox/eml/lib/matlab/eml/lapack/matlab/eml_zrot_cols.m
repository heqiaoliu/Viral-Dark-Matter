function A = eml_zrot_cols(A,c,s,xcol,ycol,ilo,ihi)
%Embedded MATLAB Private Function

%   Plane rotation of A(ilo:ihi,xcol) and A(ilo:ihi,ycol)

%   Copyright 2005-2007 The MathWorks, Inc.
%#eml

eml_must_inline;
for i = ilo : ihi
    stemp = c*A(i,xcol) + s*A(i,ycol);
    A(i,ycol) = c*A(i,ycol) - eml_conjtimes(s,A(i,xcol));
    A(i,xcol) = stemp;
end

