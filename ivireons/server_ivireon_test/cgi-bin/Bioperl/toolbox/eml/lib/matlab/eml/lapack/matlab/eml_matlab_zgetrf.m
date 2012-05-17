function [A,ipiv,info] = eml_matlab_zgetrf(m,n,A,iA0,lda)
%Embedded MATLAB Private Function

%   Adapted from xGETF2(M,N,A(IA0),LDA,IPIV,INFO)
%   -- LAPACK routine (version 3.1) --
%   Univ. of Tennessee, Univ. of California Berkeley and NAG Ltd..
%   November 2006

%   IPIV    INTEGER array, dimension (min(M,N))
%           The pivot indices; for 1 <= i <= min(M,N), row i of the
%           matrix was interchanged with row IPIV(i).
%
%   INFO    NTEGER
%           = 0: successful exit
%           > 0: if INFO = k, U(k,k) is exactly zero.

%   Copyright 2005-2010 The MathWorks, Inc.
%#eml

% Set MULT_BY_RECIP = true to replace divisions by reciprocal multiplication
MULT_BY_RECIP = false;
SAFMIN = eml_rdivide(realmin(class(A)),eps(class(A)));
ipiv = cast(1:min(m,n),eml_index_class);
info = zeros(eml_index_class);
ONE = ones(eml_index_class);
ldap1 = eml_index_plus(lda,1);
for j = ONE:min(m-1,n)
    jm1 = eml_index_minus(j,1);
    mmj = eml_index_minus(m,j);
    jj = eml_index_plus(iA0,eml_index_times(jm1,ldap1)); % iA0 + j-1 + (j-1)*lda
    jp1j = eml_index_plus(jj,1);
    % Find pivot and test for singularity.
    jpiv_offset = eml_index_minus(eml_ixamax(eml_index_plus(mmj,1),A,jj,ONE),1);
    jpiv = eml_index_plus(jj,jpiv_offset);
    if  A(jpiv) ~= 0
        % Apply the interchange to columns 1:N.
        if  jpiv_offset ~= 0
            ipiv(j) = eml_index_plus(j,jpiv_offset);
            jrow = eml_index_plus(iA0,jm1);
            jprow = eml_index_plus(jrow,jpiv_offset);
            A = eml_xswap(n,A,jrow,lda,[],jprow,lda);
        end
        % Compute elements J+1:M of J-th column.
        if MULT_BY_RECIP && abs(A(jj)) >= SAFMIN
            A = eml_xscal(mmj,eml_div(1,A(jj)),A,jp1j,ONE);
        else
            for i = jp1j:eml_index_plus(jp1j,eml_index_minus(mmj,1))
                A(i) = eml_div(A(i),A(jj));
            end
        end
    else
        info = j;
    end
    % Update trailing submatrix.
    A = eml_xgeru(mmj,eml_index_minus(n,j),-ones(class(A)),[],jp1j,ONE, ...
        [],eml_index_plus(jj,lda),lda, ...
        A,eml_index_plus(jj,ldap1),lda);
end
if info == 0 && m <= n && ~(A(m,m) ~= 0)
    info = cast(m,eml_index_class);
end
