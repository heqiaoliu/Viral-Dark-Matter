function D = utSISOLFT(D,C)
% Computes LFT(D,DIAG(C1,...,CN)) where each Cj is SISO.
% Optimized for SISO Tool use.

%   Author(s): C. Buhr
%   Copyright 1986-2010 The MathWorks, Inc.
%	$Revision: 1.1.8.2 $  $Date: 2010/02/08 22:47:09 $
nC = length(C);
Cdiag = C(1);
for ct = 2:nC
   Cdiag = append(Cdiag,C(ct));
end
[Dout,Din]=iosize(D);
sw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>
D = lft(D,Cdiag,Din-nC+1:Din,Dout-nC+1:Dout,1:nC,1:nC);
