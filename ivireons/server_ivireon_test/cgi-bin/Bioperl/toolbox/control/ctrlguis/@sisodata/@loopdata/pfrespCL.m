function S = pfrespCL(this,w,C,Tin,Tout,idxM)
% Computes closed-loop frequency response parameterized by the gain
% of the compensator C with index IDXC.
%
% PFRESPCL computes a 2x2 frequency response together with the frequency
% response of the normalized compensator C so that the closed-loop   
% frequency response hT from input TIN to output TOUT is given by
%    hT = lft(hP,g*hC)
% where g = getgain(C,'mag') is the gain of C.
%
% This parameterized representation allows for fast update when 
% dynamically modifying C.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2010/04/11 20:29:54 $

if nargin < 6
    idxM = this.Plant.getNominalModelIndex;
end

idxC = find(C == this.C);

nw = length(w);
nC = length(this.C);

% Compute plant frequency response (NC+1-by-NC+1)
h = fresp(this.Plant,w,Tin,Tout,'sim',idxM);

% Compute permutation that reorders compensators so that 
%   * IDXC is last
%   * The external I/Os are second last
idxf = [1:idxC-1 , idxC+1:nC];
perm = [idxf+1,1,idxC+1];

% Response of fixed compensators
F = zeros(nw,nC-1);
for ct=1:nC-1
   % Skip compensators with loop opened
   fh = fresp(zpk(this.C(idxf(ct))),w);
   F(:,ct) = fh(:);
end

% Response of 2x2 model P such that lft(P,C) is the plant model for the IDXOL loop
P = zeros(2,2,nw);
n = nC+1;  % row and col size
for ctw=1:nw
   Pw = h(perm,perm,ctw);
   % Close upper loops around fixed compensators
   Fw = F(ctw,:);
   for ct=1:nC-1
      Pw(ct+1:n,ct+1:n) = Pw(ct+1:n,ct+1:n) + ...
         (Pw(ct+1:n,ct) * (Fw(ct)/(1-Pw(ct,ct)*Fw(ct)))) * Pw(ct,ct+1:n);
   end
   P(:,:,ctw) = Pw(nC:n,nC:n);
end
   
% Normalized response of modified compensator
Cf = reshape(fresp(zpk(this.C(idxC),'norm'),w),nw,1);

S = struct('P',permute(P,[3 1 2]),'C',Cf,'w',w);