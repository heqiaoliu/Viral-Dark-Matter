function [a,b,c,d,OLz,OLp,OLk] = utGetLoopData(D)
% Computes open-loop dynamics and adequate state-space realization
% for root locus plots. 
%
% Note: Assumes that D is proper and has no delays.

%  Author(s): P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:03 $
Ts = D.Ts;

% Derive explicit state-space realization with order equal to the 
% structural number of open-loop poles (as returned by zpk(D))
[isProper,D] = isproper(sminreal(D),'explicit');
if ~isProper
   % Should never happen
   ctrlMsgUtils.error('Controllib:general:UnexpectedError', ...
       'Unexpected failure of descriptor-to-explicit reduction.')
end

% Extract and scale data (reduces error introduced by Hessenberg reduction)
a = D.a;  b = D.b;  c = D.c;  d = D.d;
if ~D.Scaled
   [a,b,c] = xscale(a,b,c,d,[],Ts);
end
   
% Compute structural relative degree
ns = size(a,1);
if d==0
   sd = 1;
   x = b;
   while c*x==0 && sd<ns
      sd = sd+1;   x = a*x;
   end
else
   sd = 0;
end
   
% Reduce state-space data to Hessenberg form (stabilizes trajectories of 
% roots going to Inf)
% RE: Perform this before zero computation to enhance convergence of branches
% to finite zeros (makes difference for rlocus(sys) in g297998)
M = hessabc(a,b,c);   % modif of HESS to prevent permutation of 1st column
a = M(2:ns+1,2:ns+1);
b = M(2:ns+1,1);
c = M(1,2:ns+1);

% Make sure structural relative degree is preserved (see g307745)
c(:,1:sd-1) = 0;

% Compute open-loop dynamics
OLp = eig(a);
[OLz,OLk] = sszero(a,b,c,d,[],Ts);

% Make sure number of asymptotes structurally the number of finite zeros OLZ
c(:,1:ns-length(OLz)-1) = 0;

