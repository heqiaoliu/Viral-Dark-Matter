function [D,SingularFlag] = feedback(D1,D2,indu,indy,sign)
% Feedback interconnection of FRD models.
%
%                      +--------+
%          w --------->|        |--------> z
%                      |   D1   |
%          u --->O---->|        |----+---> y
%                |     +--------+    |
%                |                   |
%                +-----[   D2   ]<---+

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:22 $
SingularFlag = false;
if nargin<3
   indy = 1:length(D1.Delay.Output);  
   indu = 1:length(D1.Delay.Input);  
   sign = -1;
else
   % INDY must be a row vector to form [indz indy] below
   indy = reshape(indy,1,length(indy)); 
end
[rs,cs,nf] = size(D1.Response);
indw = 1:cs; indw(indu) = []; 
indz = 1:rs; indz(indy) = []; 
ny = length(indy);
nz = length(indz);

% Fold in all delays in feedback path
if hasdelay(D1)
   id = D1.Delay.Input;  id(indw) = 0;
   od = D1.Delay.Output; od(indz) = 0;
   D1 = elimDelay(D1,id,od,D1.Delay.IO);
end
D2 = elimDelay(D2,D2.Delay.Input,D2.Delay.Output,D2.Delay.IO);

% Compute FRD data for feedback IC
D = D1;
R = zeros(rs,cs,nf);
hw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>
for ct=1:nf
   R1 = D1.Response(:,:,ct);
   R2 = D2.Response(:,:,ct);
   R([indz indy],:,ct) = ...
      [eye(nz) -sign*R1(indz,indu)*R2;zeros(ny,nz) eye(ny)-sign*R1(indy,indu)*R2] \ R1([indz indy],:);
end
D.Response = R;

