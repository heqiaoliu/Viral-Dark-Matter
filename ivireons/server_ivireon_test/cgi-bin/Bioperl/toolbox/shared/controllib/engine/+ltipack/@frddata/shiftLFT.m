function [IC,SingularFlag] = shiftLFT(IC,S)
% Transform IC0 to IC such that LFT(IC0,Delta) = LFT(IC,Delta-S).

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:47:04 $
[nw,nz] = size(S);
[rs,cs,nf] = size(IC.Response);
ny = rs-nz;   nu = cs-nw;   % external I/Os

% Replicate w,z channels
iu = [1:cs nu+1:cs];
iy = [1:rs ny+1:rs];
IC.Response = IC.Response(iy,iu,:);
IC.Delay.Input = IC.Delay.Input(iu,:);
IC.Delay.Output = IC.Delay.Output(iy,:);
IC.Delay.IO = IC.Delay.IO(iy,iu);

% Close loop
DS = ltipack.frddata(repmat(S,[1 1 nf]),IC.Frequency,IC.Ts);
DS.FreqUnits = IC.FreqUnits;
[IC,SingularFlag] = lft(IC,DS,cs+1:cs+nw,rs+1:rs+nz,1:nz,1:nw);