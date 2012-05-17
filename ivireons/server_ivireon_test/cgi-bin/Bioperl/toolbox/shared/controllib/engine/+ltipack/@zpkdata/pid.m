function PID = pid(D,Options)
% Converts to PID data object 

%   Author(s): Rong Chen
%   Copyright 2009-2010 MathWorks, Inc.
%	$Revision: 1.1.8.2.2.1 $  $Date: 2010/06/24 19:43:21 $
if hasdelay(D)
    ctrlMsgUtils.error('Control:ltiobject:pidNoConversionWithTimeDelay');
end
Ts = D.Ts;  IF = 'F';  DF = 'F';  % default formulas
if nargin>1 && Ts~=0
   [IF,DF] = ltipack.piddata.getTargetFormulas('F','F',Options);
end
% Compute Kp,Ki,Kd,Tf with specified formulas
k = D.k;
if k==0
   Kp = 0;  Ki = 0;  Kd = 0;  Tf = 0;
else
   % May error
   [Kp,Ki,Kd,Tf] = ltipack.piddata.convert(k*poly(D.z{1}),D.p{1},Ts,IF,DF,false);
end
% Create output
PID = ltipack.piddataP(Kp,Ki,Kd,Tf,Ts);
PID.IFormula = IF;
PID.DFormula = DF;