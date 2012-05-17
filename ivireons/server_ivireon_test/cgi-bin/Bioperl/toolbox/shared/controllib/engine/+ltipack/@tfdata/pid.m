function PID = pid(D,Options)
% Converts to PID data object 

%   Author(s): Rong Chen
%   Copyright 2009-2010 MathWorks, Inc.
%	$Revision: 1.1.8.2.2.1 $  $Date: 2010/06/24 19:43:19 $
if hasdelay(D)
    ctrlMsgUtils.error('Control:ltiobject:pidNoConversionWithTimeDelay');
end
Ts = D.Ts;  IF = 'F';  DF = 'F';  % default formulas
if nargin>1 && Ts~=0
   [IF,DF] = ltipack.piddata.getTargetFormulas('F','F',Options);
end
% Compute Kp,Ki,Kd,Tf with specified formulas
NUM = D.num{1};
DEN = D.den{1};
if all(NUM==0)
   Kp = 0;  Ki = 0;  Kd = 0;  Tf = 0;
else
   NUM = NUM/DEN(find(DEN~=0,1,'first'));
   [Kp,Ki,Kd,Tf] = ltipack.piddata.convert(NUM,roots(DEN),Ts,IF,DF,false);
end
% Create output
PID = ltipack.piddataP(Kp,Ki,Kd,Tf,Ts);
PID.IFormula = IF;
PID.DFormula = DF;