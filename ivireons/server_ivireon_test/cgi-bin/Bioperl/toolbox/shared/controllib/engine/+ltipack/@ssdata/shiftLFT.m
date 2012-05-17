function [IC,SingularFlag] = shiftLFT(IC,S)
% Transform IC0 to IC such that LFT(IC0,Delta) = LFT(IC,Delta-S).

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:47:52 $
[nw,nz] = size(S);
nfd = length(IC.Delay.Internal);
[rs,cs] = size(IC.d);
ny = rs-nz-nfd;   nu = cs-nw-nfd;   % external I/Os
nuw = nu+nw;  nyz = ny+nz;

% Replicate w,z channels
iu = [1:nuw nu+1:nuw nuw+1:nuw+nfd];
iy = [1:nyz ny+1:nyz nyz+1:nyz+nfd];
IC.b = IC.b(:,iu);
IC.c = IC.c(iy,:);
IC.d = IC.d(iy,iu);
IC.Delay.Input = IC.Delay.Input(iu(1:nu+2*nw),:);
IC.Delay.Output = IC.Delay.Output(iy(1:ny+2*nz),:);

% Close loop
DS = ltipack.ssdata([],zeros(0,nz),zeros(nw,0),S,[],IC.Ts);
[IC,SingularFlag] = lft(IC,DS,nuw+1:nu+2*nw,nyz+1:ny+2*nz,1:nz,1:nw);