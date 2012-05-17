function [info,alpha1,beta1,V] = eml_matlab_zggev(A,B)
%Embedded MATLAB Private Function

%   ZGGEV computes for a pair of N-by-N complex nonsymmetric matrices
%   (A,B), the generalized eigenvalues, W(I) = ALPHA(I) ./ BETA(I), and
%   optionally, the right generalized eigenvectors V.
%   INFO
%     = 0:  successful exit
%     =1,...,N:   The QZ iteration failed.  No eigenvectors have been
%                 calculated, but ALPHA(j) and BETA(j) should be
%                 correct for j=INFO+1,...,N.
%     = -1:       QZ iteration failed in ZHGEQZ
%
%   Adapted and specialized from ZGGEV:
%    -- LAPACK driver routine (version 3.0) --
%       Univ. of Tennessee,Univ. of California Berkeley,NAG Ltd.,
%       Courant Institute, Argonne National Lab, and Rice University
%       June 30,1999

%   Copyright 2005-2010 The MathWorks, Inc.
%#eml

if nargin < 2
    B = zeros(0,class(A));
end
info = 0;
compv = nargout >= 4;
isgen = ~(eml_is_const(size(B)) && isempty(B));
n = size(A,1);
alpha1 = complex(zeros(n,1,class(A)));
beta1 = complex(zeros(n,1,class(A)));
if compv
    V = complex(zeros(n,class(A)));
end
if isempty(A)
    return
end
% Machine constants.
SMLNUM = eml_rdivide(sqrt(realmin(class(A))),eps(class(A)));
BIGNUM = eml_rdivide(1,SMLNUM);
% Scale A if max element outside range [SMLNUM,BIGNUM].
anrm = eml_matlab_zlangeM(A);
if ~isfinite(anrm)
    % Nonfinite A so return NaNs.
    alpha1 = complex(zeros(n,1,class(A))) + eml_guarded_nan(class(A));
    beta1 = complex(zeros(n,1,class(A))) + eml_guarded_nan(class(A));
    if compv
        V = complex(zeros(n,class(A)) + eml_guarded_nan(class(A)));
    end
    return
end
ilascl = false;
anrmto = anrm;
if anrm > 0 && anrm < SMLNUM
    anrmto = SMLNUM;
    ilascl = true;
elseif anrm > BIGNUM
    anrmto = BIGNUM;
    ilascl = true;
end
if ilascl
    A = eml_matlab_zlascl(anrm,anrmto,A);
end
% Dummy initialisations to silence def-before-use checking.
ilbscl = false;
bnrm = zeros(class(B));
bnrmto = zeros(class(B));
if isgen
    % Scale B if max element outside range [SMLNUM,BIGNUM].
    bnrm = eml_matlab_zlangeM(B);
    bnrmto = bnrm;
    if bnrm > 0 && bnrm < SMLNUM
        bnrmto = SMLNUM;
        ilbscl = true;
    elseif bnrm > BIGNUM
        bnrmto = BIGNUM;
        ilbscl = true;
    end
    if ilbscl
        B = eml_matlab_zlascl(bnrm,bnrmto,B);
    end
end
% Permute the matrices A, B to isolate eigenvalues if possible.
[A,B,ilo,ihi,rscale] = eml_matlab_zggbal(A,B);
% Reduce B to triangular form (QR decomposition of B).
if compv
    lastcol = cast(n,eml_index_class);
else
    lastcol = ihi;
end
if isgen
    [B,tau] = eml_matlab_zgeqr2(B,ilo,ihi,lastcol);
    % Apply the orthogonal transformation to matrix A
    A = eml_matlab_zunmqr(B,tau,A,ilo,ihi,lastcol);
end
% Initialize V and reduce to generalized hessenberg form.
% Perform QZ algorithm (compute eigenvalues, and optionally, the
% Schur form and Schur vectors).
if compv
    [A,B,~,V] = eml_matlab_zgghrd('N','I',ilo,ihi,A,B);
    [info,alpha1,beta1,A,B,V] = eml_matlab_zhgeqz(A,B,ilo,ihi,V);
    if info ~= 0
        return
    end
    % Compute eigenvectors.
    V = eml_matlab_ztgevc(A,B,V);
    % Undo balancing and normalization.
    V = eml_matlab_zggbak(V,ilo,ihi,rscale);
    for jc = 1 : n
        vtemp = abs1(V(1,jc));
        if n > 1
            for jr = 2 : n
                vtemp = max2(vtemp,abs1(V(jr,jc)));
            end
        end
        if vtemp >= SMLNUM
            vtemp = eml_rdivide(1,vtemp);
            for jr = 1 : n
                V(jr,jc) = V(jr,jc) * vtemp;
            end
        end
    end
else
    [A,B] = eml_matlab_zgghrd('N','N',ilo,ihi,A,B);
    [info,alpha1,beta1] = eml_matlab_zhgeqz(A,B,ilo,ihi);
    if info ~= 0
        return
    end
end

% Undo scaling if necessary.
if ilascl
    alpha1 = eml_matlab_zlascl(anrmto,anrm,alpha1);
end
if isgen && ilbscl
    beta1 = eml_matlab_zlascl(bnrmto,bnrm,beta1);
end

%--------------------------------------------------------------------------

function x = max2(x,y)
eml_must_inline;
% Simple maximum of 2 elements.  Output class is class(x).
if y > x
    x = cast(y,class(x));
end

%--------------------------------------------------------------------------

function y = abs1(x)
eml_must_inline;
y = abs(real(x)) + abs(imag(x));

%--------------------------------------------------------------------------
