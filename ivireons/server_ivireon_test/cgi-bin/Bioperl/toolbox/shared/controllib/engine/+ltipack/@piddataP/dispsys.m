function dispsys(PID)
%DISPLAY

%   Author(s): Rong Chen
%   Copyright 2009 MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2010/02/08 22:47:29 $

if PID.Ts==0
    StrSampleTime = '';
else
    StrSampleTime = [', Ts = ' num2str(PID.Ts)];
end
disp(' ');
switch PID.getType
    case 'P'
        disp(['Kp = ' num2str(PID.Kp) StrSampleTime]);
    case 'I'
        StrI = ltipack.piddata.utGetStrI(PID.Ts,PID.IFormula);
        disp([blanks(5) StrI(1,:)]);
        disp(['Ki * ' StrI(2,:)]);
        disp([blanks(5) StrI(3,:)]);
        disp(' ');
        disp(['with Ki = ' num2str(PID.Ki) StrSampleTime]);
    case 'PI'
        StrI = ltipack.piddata.utGetStrI(PID.Ts,PID.IFormula);
        disp([blanks(10) StrI(1,:)]);
        disp(['Kp + Ki * ' StrI(2,:)]);
        disp([blanks(10) StrI(3,:)]);
        disp(' ');
        disp(['with Kp = ' num2str(PID.Kp) ', Ki = ' num2str(PID.Ki) StrSampleTime]);
    case 'PD'
        StrD = ltipack.piddata.utGetStrForS(PID.Ts,PID.DFormula);
        disp([blanks(10) StrD(1,:)]);
        disp(['Kp + Kd * ' StrD(2,:)]);
        disp([blanks(10) StrD(3,:)]);
        disp(' ');
        disp(['with Kp = ' num2str(PID.Kp) ', Kd = ' num2str(PID.Kd) StrSampleTime]);
    case 'PDF'            
        StrD = ltipack.piddata.utGetStrD_Parallel(PID.Ts,PID.DFormula);
        disp([blanks(10) StrD(1,:)]);
        disp(['Kp + Kd * ' StrD(2,:)]);
        disp([blanks(10) StrD(3,:)]);
        disp(' ');
        disp(['with Kp = ' num2str(PID.Kp) ', Kd = ' num2str(PID.Kd) ', Tf = ' num2str(PID.Tf) StrSampleTime]);
        disp(' ');
    case 'PID'                        
        StrI = ltipack.piddata.utGetStrI(PID.Ts,PID.IFormula);
        StrD = ltipack.piddata.utGetStrForS(PID.Ts,PID.DFormula);
        disp([blanks(10) StrI(1,:) blanks(8) StrD(1,:)]);
        disp(['Kp + Ki * ' StrI(2,:) ' + Kd * ' StrD(2,:)]);
        disp([blanks(10) StrI(3,:) blanks(8) StrD(3,:)]);
        disp(' ');
        disp(['with Kp = ' num2str(PID.Kp) ', Ki = ' num2str(PID.Ki) ', Kd = ' num2str(PID.Kd) StrSampleTime]);
    case 'PIDF'            
        StrI = ltipack.piddata.utGetStrI(PID.Ts,PID.IFormula);
        StrD = ltipack.piddata.utGetStrD_Parallel(PID.Ts,PID.DFormula);
        disp([blanks(10) StrI(1,:) blanks(8) StrD(1,:)]);
        disp(['Kp + Ki * ' StrI(2,:) ' + Kd * ' StrD(2,:)]);
        disp([blanks(10) StrI(3,:) blanks(8) StrD(3,:)]);
        disp(' ');
        disp(['with Kp = ' num2str(PID.Kp) ', Ki = ' num2str(PID.Ki) ', Kd = ' num2str(PID.Kd) ', Tf = ' num2str(PID.Tf) StrSampleTime]);
end
disp(' ');

