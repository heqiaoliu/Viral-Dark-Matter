function S = pfrespOL(this,w,C,Cnorm,idxM)
% Parameterizes the open-loop frequency response in terms of the  
% currently edited compensator C.
%
% PFRESPOL computes a 2x2 frequency response hP together with the
% normalized (initial) frequency response hC of the compensator C 
% so that the frequency response hOL of the tuned loop THIS is  
% given by
%    hOL = gCnorm * lft(hP,gC*hC)
% where
%   * gC = getgain(C,'mag') is the gain of C
%   * gCnorm = getgain(Cnorm,'mag') is the gain of the compensator
%     Cnorm with respect to which the tuned loop THIS should be 
%     normalized.
%
% This parameterization allows for fast update of the open-loop 
% frequency-domain editors when dynamically modifying C.  The 
% normalization wrt Cnorm avoids Divide by Zero issues when the
% loop gain (gain of Cnorm) is zero.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2010/03/26 17:22:08 $

if nargin < 5
    idxM = this.Nominal;
end


% Note: Assumes that C is not a Tuned Factor for the tuned loop THIS
% (see grapheditor/addlisteners)
nw = length(w);
hP = zeros(2,2,nw);
TunedFactors = this.TunedFactors;
TunedLFT = this.TunedLFT;
nBlocks = length(TunedLFT.Blocks);
idxB = find(C==TunedLFT.Blocks); % assumed to be single index

% Compute frequency response of Tuned Factors
hTF = ones(1,1,nw);
for ct = 1:length(TunedFactors);
   if TunedFactors(ct)==Cnorm
      hTF = hTF .* fresp(zpk(Cnorm,'normalized'),w);
   else
      hTF = hTF .* fresp(zpk(TunedFactors(ct)),w);
   end
end

% Frequency response of C
hC = fresp(zpk(C,'norm'),w);

% Frequency response of IC
hIC = fresp(TunedLFT.IC(idxM), w);

% Move C to second I/O pair in IC
otherBlocks = [1:idxB-1 idxB+1:nBlocks];
perm = [1 1+idxB 1+otherBlocks];
hIC = hIC(perm,perm,:);

% Frequency response of remaining blocks
hOB = zeros(nBlocks-1,1,nw);
for ct=1:nBlocks-1
   hOB(ct,1,:) = fresp(zpk(TunedLFT.Blocks(otherBlocks(ct))),w);
end

% Compute hP by closing lower loops on remaining blocks
idxLower = 3:nBlocks+1;
for ct=1:nw
   s = hOB(:,1,ct);
   hP(:,:,ct) = hIC([1 2],[1 2],ct) + lrscale(hIC([1 2],idxLower,ct),[],s) * ...
      ((eye(nBlocks-1)-lrscale(hIC(idxLower,idxLower,ct),[],s)) \ hIC(idxLower,[1 2],ct));
end

% Add contribution of tuned factors and
% account for assumed negative feedback
hP(1,:,:) = -hP(1,:,:) .* hTF(1,[1 1],:);

% Build data structure
S = struct('P',permute(hP,[3 1 2]),'C',hC(:),'w',w);
