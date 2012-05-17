function [ac,bc,cc,dc,x0c] = md2c(a,b,c,d,x0,T)
% Bilinear transformation

% Copyright 2002-2008 The MathWorks, Inc.
%   $Revision: 1.1.4.3 $  $Date: 2008/10/02 18:51:42 $

if nargin<6, % No x0
    T = x0;
    x0 = zeros(size(a,1),1);
end
I = eye(size(a));
[l,u,p] = lu(I + a);
if rcond(u)<eps,
    ctrlMsgUtils.error('Ident:transformation:bilind2c1')
end
ac = 2/T * (u\(l\(p*(a-I))));
btmp = (u\(l\(p*b)));
bc = 2/sqrt(T) * btmp;
cc = 2/sqrt(T) *  ((c/u)/l)*p;
dc = d - c*btmp;
x0c = 2/sqrt(T) * (u\(l\(p*x0)));
