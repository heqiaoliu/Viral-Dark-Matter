function S = pOpenLoop(this,C_tuned,C_ol,idxM)
% Computes parametric open-loop model for fast root locus update.
%
% The parameterization is in terms of the currently tuned block C_tuned, 
% which is assumed to be indirectly tunable for the open loop THIS.
% The parametric open-loop model is further normalized with respect to 
% the tuned factor C_OL.  This allows for fast update of the root locus 
% plot (for the open loop THIS) when modifying C_tuned.
%
% pOpenLoop computes a 2x2 @ssdata model G22 and a SISO @ssdata model C 
% such that the normalized open loop (with respect to C_OL) is given by
%    OL = C * lft(G22,ss(C_tuned))
% Note that C collects all tuned factors for the C_OL loop, including 
% the normalized C_OL.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2010/03/26 17:22:07 $

if nargin < 4
    idxM = this.Nominal;
end

TunedFactors = this.TunedFactors;
TunedLFTBlocks = this.TunedLFT.Blocks;  % indirectly tunable for this loop

% Initialize C with normalized C_OL tuned factor
% Note: Flip sign to account for negative feedback assumed by root locus
% editor
C = zpk(C_ol,'norm');
C.k = -C.k;

% Fold remaining tuned factors into C
% RE: Use ZPK form for efficiency and to avoid
%     extra states when some factors are improper
for ct=1:length(TunedFactors)
   TF = TunedFactors(ct);
   if TF~=C_ol
      C = C * zpk(TF);
   end
end

% Compute 2x2 model G22
idxB = find(C_tuned==TunedLFTBlocks);
nB = length(TunedLFTBlocks);
perm = [idxB 1:idxB-1 idxB+1:nB]; % Move C_tuned upfront in block list
idxG = [1 1+perm];
G22 = getsubsys(this.TunedLFT.IC(idxM),idxG,idxG); 
% Close the lower loops around fixed comps
% RE: No structural reduction here (performed later by RLOCUS)
for ct=nB:-1:2
   G22 = utSISOLFT(G22,ss(TunedLFTBlocks(perm(ct))));
end

% Collect tuned poles and zeros
[zC,pC] = getTunedPZ(this);

% Build output
S = struct('G22',G22,'C',ss(C),'TunedZero',zC,'TunedPole',pC);
