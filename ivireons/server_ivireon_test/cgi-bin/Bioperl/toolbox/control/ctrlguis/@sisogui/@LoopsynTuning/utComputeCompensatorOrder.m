function Nk = utComputeCompensatorOrder(this)
%utComputeCompensatorOrder Computes the order of the compensator based on G
% and Gd (based on formula specified in the doc for loopsyn)

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2009/05/23 07:53:08 $

Ny = 1;
Gd = this.getGd;

G = this.utApproxDelay(this.OpenLoopPlant);

PolesG = pole(G);
ZerosG = zero(G);
PZG = [PolesG(:); ZerosG(:)];

NGd = order(Gd);
NG = length(PolesG);

if isdt(G)
    NGrhp = length(PZG(abs(PZG) >= 1)) + length(PolesG) - length(ZerosG);
else
    NGrhp = length(PZG(real(PZG) >= 0)) + length(PolesG) - length(ZerosG);
end

Nk = Ny*NGd + NGrhp + NG;