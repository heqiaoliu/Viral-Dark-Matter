function dispsys(PID)
%DISPLAY

%   Author(s): Rong Chen
%   Copyright 2009 MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2010/02/08 22:47:35 $

if PID.Ts==0
    StrSampleTime = '';
else
    StrSampleTime = [', Ts = ' num2str(PID.Ts)];
end
disp(' ');
switch PID.getType
    case 'P'
        disp(['Kp = ' num2str(PID.Kp) StrSampleTime]);
    case 'PI'
        StrI = ltipack.piddata.utGetStrI(PID.Ts,PID.IFormula);
        disp(['           1     ' StrI(1,:)]);
        disp(['Kp * (1 + ---- * ' StrI(2,:) ')']);
        disp(['           Ti    ' StrI(3,:)]);
        disp(' ');
        disp(['with Kp = ' num2str(PID.Kp) ', Ti = ' num2str(PID.Ti) StrSampleTime]);
    case 'PD'
        StrD = ltipack.piddata.utGetStrForS(PID.Ts,PID.DFormula);
        disp([blanks(15) StrD(1,:)]);
        disp(['Kp * (1 + Td * ' StrD(2,:) ')']);
        disp([blanks(15) StrD(3,:)]);
        disp(' ');
        disp(['with Kp = ' num2str(PID.Kp) ', Td = ' num2str(PID.Td) StrSampleTime]);
    case 'PDF'            
        StrD = ltipack.piddata.utGetStrD_Standard(PID.Ts,PID.DFormula);
        disp([blanks(15) StrD(1,:)]);
        disp(['Kp * (1 + Td * ' StrD(2,:) ')']);
        disp([blanks(15) StrD(3,:)]);
        disp(' ');
        disp(['with Kp = ' num2str(PID.Kp) ', Td = ' num2str(PID.Td) ', N = ' num2str(PID.N) StrSampleTime]);
    case 'PID'                        
        StrI = ltipack.piddata.utGetStrI(PID.Ts,PID.IFormula);
        StrD = ltipack.piddata.utGetStrForS(PID.Ts,PID.DFormula);
        disp(['           1     ' StrI(1,:) blanks(8) StrD(1,:)]);
        disp(['Kp * (1 + ---- * ' StrI(2,:) ' + Td * ' StrD(2,:) ')']);
        disp(['           Ti    ' StrI(3,:) blanks(8) StrD(3,:)]);
        disp(' ');
        disp(['with Kp = ' num2str(PID.Kp) ', Ti = ' num2str(PID.Ti) ', Td = ' num2str(PID.Td) StrSampleTime]);
    case 'PIDF'            
        StrI = ltipack.piddata.utGetStrI(PID.Ts,PID.IFormula);
        StrD = ltipack.piddata.utGetStrD_Standard(PID.Ts,PID.DFormula);
        disp(['           1     ' StrI(1,:) blanks(8) StrD(1,:)]);
        disp(['Kp * (1 + ---- * ' StrI(2,:) ' + Td * ' StrD(2,:) ')']);
        disp(['           Ti    ' StrI(3,:) blanks(8) StrD(3,:)]);
        disp(' ');
        disp(['with Kp = ' num2str(PID.Kp) ', Ti = ' num2str(PID.Ti) ', Td = ' num2str(PID.Td) ', N = ' num2str(PID.N) StrSampleTime]);
end
disp(' ');

