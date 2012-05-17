function Q = fipert_qr(A,B,C)
%FIPERT_QR  private function

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2008/10/02 18:52:30 $

[n,m]  = size(B);
In = eye(n);

X = [ kron(A.',In) - kron(In,A) ; kron(B.',In) ;- kron(In,C)];
[m,z] = size(X);

[QQ,R] = qr(X);
Q = QQ(:,n*n+1:m);

