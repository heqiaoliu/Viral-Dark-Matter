function [a,Terms,thn,rho,nzB,nzC,nzD] = c2dSetUp(Dc,Ts,fid,fod,tol)
% Setup for c2d discretization with internal delays
% (assumes isExplicitODE(Dc) is true). Extracts a
% DELAYSS-like representation of the continuous-time
% state equations:
%     dx/dt = a x + sum Bj u(t-theta_j)
%     y = sum Cj x(t-thetaj) + Dj u(t-theta_j)

%   Author(s): P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:11 $

% Add static method to be included for compiler
%#function ltipack.splitDelay

% Turn residual fractional input and output delays into internal delays
if any(fid) || any(fod)
   Dc = utFoldDelay(Dc,fid*Ts,fod*Ts);
end

% Extract data
[a,b1,b2,c1,c2,d11,d12,d21,d22] = getBlockData(Dc);

% Eliminate Z,W from DDAE to derive ODE with input and output delays
Terms = elimZW(b2,d12,c2,d21,d22,Dc.Delay.Internal);

% Add [0 b1;c1 d11] as term with zero delay
Terms = [struct('theta',0,'b',b1,'c',c1,'d',d11) ; Terms];

% Decompose cumulative delays theta and sort by rho values
% RE: rho are the normalized fractional delays, valued in [0,1)
[N,rho] = ltipack.splitDelay(cat(1,Terms.theta),Ts);
[rho,is] = sort(rho);
rho = cleanEvents(rho,tol);  % equate entries that differ by o(eps)
thn = N(is) + rho;           % thetaj/Ts
Terms = Terms(is);  

% Construct logical vectors to keep track of nonzero terms
% nzB is true for terms with nonzero B matrix,...
nt = length(Terms);
nzB = false(nt,1);
nzC = false(nt,1);
nzD = false(nt,1);
for ct=1:nt
   t = Terms(ct);
   nzB(ct) = (norm(t.b,1)>0);
   nzC(ct) = (norm(t.c,1)>0);   
   nzD(ct) = (norm(t.d,1)>0);   
end