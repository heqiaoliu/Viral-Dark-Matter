function Q = utComputeProjection(struc)
% compute data-driven projection

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/10/02 18:52:08 $

dkx = struc.dkx;
%m = struc.nu;
p = struc.ny;
n = struc.nx;
nk = struc.nk;
if dkx(2)
    bk = [struc.b struc.k];
else
    bk = struc.b;
end

Q = local_fipert_qr(struc.a,bk,struc.c);
if isempty(nk)
    nextra = dkx(3)*n;
else
    nextra = dkx(1)*sum(nk==0)*p+dkx(3)*n;
end

if nextra>0,
    Q = [Q, zeros(size(Q,1),nextra);...
        zeros(nextra, size(Q,2)), eye(nextra)];
end

%--------------------------------------------------------------------------
function Q = local_fipert_qr(A,B,C)
%FIPERT_QR  computes data-based projection matrix

[n,m]  = size(B);
In = eye(n);

X = [ kron(A.',In) - kron(In,A) ; kron(B.',In) ;- kron(In,C)];
[m,z] = size(X);

[QQ,R] = qr(X);
Q = QQ(:,n*n+1:m);
