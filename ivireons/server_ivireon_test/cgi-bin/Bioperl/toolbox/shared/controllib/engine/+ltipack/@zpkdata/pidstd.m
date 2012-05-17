function PIDS = pidstd(D,Options)
% Converts to PIDS data object (Standard Form)

%   Author(s): Rong Chen
%   Copyright 2009-2010 MathWorks, Inc.
%	$Revision: 1.1.8.2.2.1 $  $Date: 2010/06/24 19:43:22 $
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
   [Kp,Ki,Kd,Tf] = ltipack.piddata.convert(k*poly(D.z{1}),D.p{1},Ts,IF,DF,true);
end
[Kp,Ti,Td,N] = ltipack.piddata.convertPIDF('Parallel','Standard',Kp,Ki,Kd,Tf);
% Create output
PIDS = ltipack.piddataS(Kp,Ti,Td,N,Ts);
PIDS.IFormula = IF;
PIDS.DFormula = DF;