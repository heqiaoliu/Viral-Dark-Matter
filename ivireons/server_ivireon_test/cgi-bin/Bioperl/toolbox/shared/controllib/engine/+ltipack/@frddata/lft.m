function [D,SingularFlag] = lft(D1,D2,indu1,indy1,indu2,indy2)
% LFT interconnection of FRD models.
%		
%                        +-------+
%            w1 -------->|       |-------> z1
%                        |   D1  |
%                  +---->|       |-----+
%                  |     +-------+     |
%                u |                   | y
%                  |     +-------+     |
%                  +-----|       |<----+
%                        |   D2  |
%           z2 <---------|       |-------- w2
%                        +-------+

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:38 $
SingularFlag = false;
[rs1,cs1,nf] = size(D1.Response);   %#ok<NASGU>
indw1 = 1:cs1; indw1(indu1) = []; nw1 = length(indw1);
indz1 = 1:rs1; indz1(indy1) = []; nz1 = length(indz1);
[rs2,cs2,nf] = size(D2.Response);  
indw2 = 1:cs2; indw2(indu2) = []; nw2 = length(indw2);
indz2 = 1:rs2; indz2(indy2) = []; nz2 = length(indz2);
nu = length(indu1);
ny = length(indy1);

% Fold all delays in feedback path
if hasdelay(D1)
   id = D1.Delay.Input;  id(indw1) = 0;
   od = D1.Delay.Output; od(indz1) = 0;
   D1 = elimDelay(D1,id,od,D1.Delay.IO);
end
if hasdelay(D2)
   id = D2.Delay.Input;  id(indw2) = 0;
   od = D2.Delay.Output; od(indz2) = 0;
   D2 = elimDelay(D2,id,od,D2.Delay.IO);
end

% Construct result
D = D1;
D.Delay.Input = [D1.Delay.Input(indw1,:) ; D2.Delay.Input(indw2,:)];
D.Delay.Output = [D1.Delay.Output(indz1,:) ; D2.Delay.Output(indz2,:)];
D.Delay.IO = zeros(nz1+nz2,nw1+nw2);

% Response data
R = zeros(nz1+nz2,nw1+nw2,nf);
hw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>
for ct=1:nf
   R1 = D1.Response(:,:,ct);
   R2 = D2.Response(:,:,ct);
   M = [eye(nu) -R2(indy2,indu2);-R1(indy1,indu1) eye(ny)] \...
      [zeros(nu,nw1) R2(indy2,indw2);R1(indy1,indw1) zeros(ny,nw2)];
   R(:,:,ct) = [R1(indz1,indw1) zeros(nz1,nw2) ; zeros(nz2,nw1) R2(indz2,indw2)] + ...
      [R1(indz1,indu1) * M(1:nu,:) ; R2(indz2,indu2) * M(nu+1:nu+ny,:)];
end
D.Response = R;

