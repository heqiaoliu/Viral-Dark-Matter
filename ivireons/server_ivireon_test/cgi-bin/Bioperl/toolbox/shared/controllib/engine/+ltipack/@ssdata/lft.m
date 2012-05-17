function [D1,SingularFlag] = lft(D1,D2,indu1,indy1,indu2,indy2)
% LFT interconnection of states-space models.
%		
%                        +-------+
%            w1 -------->|       |-------> z1
%                        |  SYS1 |
%                  +---->|       |-----+
%                  |     +-------+     |
%                u |                   | y
%                  |     +-------+     |
%                  +-----|       |<----+
%                        |  SYS2 |
%           z2 <---------|       |-------- w2
%                        +-------+
%

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:36:18 $

% Sizes
[rs1,cs1] = iosize(D1);
indw1 = 1:cs1; indw1(indu1) = []; nw1 = length(indw1);
indz1 = 1:rs1; indz1(indy1) = []; nz1 = length(indz1);
[rs2,cs2] = iosize(D2);
indw2 = 1:cs2; indw2(indu2) = []; nw2 = length(indw2);
indz2 = 1:rs2; indz2(indy2) = []; nz2 = length(indz2);
nu = length(indu1);
ny = length(indy1);
nx1 = size(D1.a,1);
nx2 = size(D2.a,1);

% Fold in all delays in feedback path. D1's I/O delays are absorbed 
% into D2 and all I/O delays of D2 are then folded in.
Delay1 = D1.Delay;
Delay2 = D2.Delay;
D2in = zeros(size(Delay2.Input));
D2in(indu2,:) = Delay2.Input(indu2,:) + Delay1.Output(indy1,:);
D2out = zeros(size(Delay2.Output));
D2out(indy2,:) = Delay2.Output(indy2,:) + Delay1.Input(indu1,:);
if any(D2in) || any(D2out)
   Delay1.Input(indu1,:) = 0;
   Delay1.Output(indy1,:) = 0;
   %D2 = copy(D2); g180039   
   D2.Delay.Input(indu2) = D2in(indu2);
   D2.Delay.Output(indy2) = D2out(indy2);
   D2 = utFoldDelay(D2,D2in,D2out);
   Delay2 = D2.Delay;
end
nfd1 = length(Delay1.Internal);
nfd2 = length(Delay2.Internal);

% Resulting delays
Delay1.Input = [Delay1.Input(indw1,:)  ; Delay2.Input(indw2,:)];
Delay1.Output = [Delay1.Output(indz1,:) ; Delay2.Output(indz2,:)];
Delay1.Internal = [Delay1.Internal ; Delay2.Internal];

% Compute realization for feedback interconnection as
%    [a b;c d] + [bF,xF] * inv(M) * [cF,yF]
if isempty(D1.StateName) && isempty(D2.StateName)
   StateName = [];
else
   StateName = [ltipack.fullstring(D1.StateName,nx1) ; ltipack.fullstring(D2.StateName,nx2)];
end
if isempty(D1.StateUnit) && isempty(D2.StateUnit)
   StateUnit = [];
else
   StateUnit = [ltipack.fullstring(D1.StateUnit,nx1) ; ltipack.fullstring(D2.StateUnit,nx2)];
end
e = utBlkDiagE(D1.e,D2.e,nx1,nx2);
Ts = D1.Ts;

% Form auxiliary matrices
a = [D1.a zeros(nx1,nx2) ; zeros(nx2,nx1) D2.a];
b = [D1.b(:,indw1) zeros(nx1,nw2) ; zeros(nx2,nw1) D2.b(:,indw2)];
c = [D1.c(indz1,:) zeros(nz1,nx2) ; zeros(nz2,nx1) D2.c(indz2,:)];
d = [D1.d(indz1,indw1) zeros(nz1,nw2);zeros(nz2,nw1) D2.d(indz2,indw2)];
xF = [zeros(nz1,ny) D1.d(indz1,indu1);D2.d(indz2,indu2) zeros(nz2,nu)];
bF = [zeros(nx1,ny) D1.b(:,indu1);D2.b(:,indu2) zeros(nx2,nu)];
yF = [D1.d(indy1,indw1) zeros(ny,nw2);zeros(nu,nw1) D2.d(indy2,indw2)];
cF = [D1.c(indy1,:) zeros(ny,nx2);zeros(nu,nx1) D2.c(indy2,:)];
if nfd1>0 || nfd2>0
   % Add internal delay contributions
   b = [b , blkdiag(D1.b(:,cs1+1:cs1+nfd1),D2.b(:,cs2+1:cs2+nfd2))];
   c = [c ; blkdiag(D1.c(rs1+1:rs1+nfd1,:),D2.c(rs2+1:rs2+nfd2,:))];
   d = [d , ...
         blkdiag(D1.d(indz1,cs1+1:cs1+nfd1),D2.d(indz2,cs2+1:cs2+nfd2)) ; ...
         blkdiag(D1.d(rs1+1:rs1+nfd1,indw1),D2.d(rs2+1:rs2+nfd2,indw2)) , ...
         blkdiag(D1.d(rs1+1:rs1+nfd1,cs1+1:cs1+nfd1),D2.d(rs2+1:rs2+nfd2,cs2+1:cs2+nfd2))];
   xF = [xF ; zeros(nfd1,ny) D1.d(rs1+1:rs1+nfd1,indu1) ; ...
         D2.d(rs2+1:rs2+nfd2,indu2) zeros(nfd2,nu)];
   yF = [yF , blkdiag(D1.d(indy1,cs1+1:cs1+nfd1),D2.d(indy2,cs2+1:cs2+nfd2))];
end

% Compute closed loop matrices
[D1.a,D1.b,D1.c,D1.d,D1.e,D1.StateName,D1.StateUnit,SingularFlag] = getClosedLoop(...
   a,b,c,d,e,Ts,StateName,StateUnit,bF,cF,xF,yF,D1.d(indy1,indu1),D2.d(indy2,indu2));
D1.Delay = Delay1;
D1.Scaled = false;
