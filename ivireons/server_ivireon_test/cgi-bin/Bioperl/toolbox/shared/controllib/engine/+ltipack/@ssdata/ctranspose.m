function Dt = ctranspose(D)
% Pertransposition of state-space models.
%
%   For a continuous-time model SYS with data (A,B,C,D), 
%   CTRANSPOSE produces the state-space model TSYS with
%   data (-A',-C',B',D').  If H(s) is the transfer function 
%   of SYS, then H(-s).' is the transfer function of TSYS.
%
%   For a discrete-time model SYS with data (A,B,C,D), TSYS
%   is the state-space model with data 
%       (AA, AA*C', -B'*AA, D'-B'*AA*C')  with AA=inv(A').
%   Equivalently, H(z^-1).' is the transfer function of TSYS
%   if H(z) is the transfer function of SYS.

%   Author(s): P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:49 $
Ts = D.Ts;

% Compute pertranspose
if Ts==0,
   % Continuous-time case
   Dt = ltipack.ssdata(-D.a',-D.c',D.b',D.d',D.e',Ts);
   Dt.Scaled = D.Scaled;
else
   % Discrete time
   [a,b,c,d,e] = getABCDE(D);
   nx = size(a,1);
   [ny,nu] = size(d);
   et = [a' c';zeros(ny,nx+ny)];
   at = blkdiag(e',eye(ny));
   bt = [zeros(nx,ny) ; -eye(ny)];
   ct = [b' , zeros(nu,ny)];
   Dt = ltipack.ssdata(at,bt,ct,d',et,Ts);
   % Note: Do not reduce here. This requires scaling and users would have
   % no way to address scaling issues
end
Dt.Delay = transposeDelay(D);
