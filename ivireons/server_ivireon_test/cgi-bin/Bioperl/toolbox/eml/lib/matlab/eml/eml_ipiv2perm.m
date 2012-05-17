function perm = eml_ipiv2perm(ipiv,m)
%Embedded MATLAB Private Function

%   Convert a LAPACK XGETRF IPIV vector for a matrix with m rows to a
%   corresponding permutation vector.
%
%   IPIV for an M x N matrix is a vector of length min(M,N) with entries
%   between 1 and M.

%   Copyright 2005-2009 The MathWorks, Inc.
%#eml

eml_prefer_const(m);
perm = cast(1:m,eml_index_class);
nipiv = eml_numel(ipiv);
if eml_is_const(m == nipiv) && m == nipiv
    kmax = nipiv - 1;
else
    kmax = nipiv;
end
for k = 1:kmax
    ipk = ipiv(k);
    if ipk > k
        % In all cases ipk <= m.
        pipk = perm(ipk);
        perm(ipk) = perm(k);
        perm(k) = pipk;
    end
end
