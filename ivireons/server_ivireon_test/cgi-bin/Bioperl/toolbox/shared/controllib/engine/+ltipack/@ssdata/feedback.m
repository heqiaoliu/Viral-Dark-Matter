function [D,SingularFlag] = feedback(D1,D2,indu,indy,sign)
% Feedback interconnection of states-space models.
%
%                      +--------+
%          w --------->|        |--------> z
%                      |   D1   |
%          u --->O---->|        |----+---> y
%                |     +--------+    |
%                |                   |
%                +-----[   D2   ]<---+

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:36:15 $
if nargin<3
   indy = 1:length(D1.Delay.Output);  
   indu = 1:length(D1.Delay.Input);  
   sign = -1;
end
nu = length(indu);
ny = length(indy);

% All input and output delays in feedback path become internal
[Delay,D1,D2] = localCombineDelay(D1,D2,indu,indy);

% Sizes   
[rs1,cs1] = size(D1.d);  
nfd2 = length(D2.Delay.Internal);
rs2 = nu+nfd2;
cs2 = ny+nfd2;
nx1 = size(D1.a,1);
nx2 = size(D2.a,1);

% Compute realization for feedback interconnection as
%    [a b;c d] + [bF;xF] * inv(M) * [cF,yF]
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
b = [D1.b zeros(nx1,nfd2);zeros(nx2,cs1) D2.b(:,ny+1:cs2)];
c = [D1.c zeros(rs1,nx2);zeros(nfd2,nx1) D2.c(nu+1:rs2,:)];
if nfd2>0
   d = blkdiag(D1.d,D2.d(nu+1:rs2,ny+1:cs2));
else
   d = D1.d;
end
bF = [zeros(nx1,ny) sign*D1.b(:,indu) ; D2.b(:,1:ny) zeros(nx2,nu)];
cF = [D1.c(indy,:) zeros(ny,nx2);zeros(nu,nx1) D2.c(1:nu,:)];
xF = [zeros(rs1,ny) , sign*D1.d(:,indu); D2.d(nu+1:rs2,1:ny) zeros(nfd2,nu)];
yF = [D1.d(indy,:) zeros(ny,nfd2) ; zeros(nu,cs1) D2.d(1:nu,ny+1:cs2)];

% Compute closed loop matrices
[a,b,c,d,e,StateName,StateUnit,SingularFlag] = getClosedLoop(...
   a,b,c,d,e,Ts,StateName,StateUnit,bF,cF,xF,yF,sign*D1.d(indy,indu),D2.d(1:nu,1:ny));

% Build output
D = ltipack.ssdata(a,b,c,d,e,Ts);
D.StateName = StateName;
D.StateUnit = StateUnit;
D.Delay = Delay;

%---------------------------

function [Delay,D1,D2] = localCombineDelay(D1,D2,indu,indy)
% Delay management for FEEDBACK

% Fold in all delays in feedback path
Delay1 = D1.Delay;
D1in = zeros(size(Delay1.Input));
D1in(indu) = Delay1.Input(indu);
D1out = zeros(size(Delay1.Output));
D1out(indy) = Delay1.Output(indy);
if any(D1in) || any(D1out)
   D1.Delay.Input(indu,:) = 0;
   D1.Delay.Output(indy,:) = 0;
   D1 = utFoldDelay(D1,D1in,D1out);
end

Delay2 = D2.Delay;
if any(Delay2.Input) || any(Delay2.Output)
   D2 = utFoldDelay(D2,Delay2.Input,Delay2.Output);
end

% Build delay structure for interconnection
Delay = Delay1;
Delay.Input = D1.Delay.Input;
Delay.Output = D1.Delay.Output;
Delay.Internal = [D1.Delay.Internal ; D2.Delay.Internal];

