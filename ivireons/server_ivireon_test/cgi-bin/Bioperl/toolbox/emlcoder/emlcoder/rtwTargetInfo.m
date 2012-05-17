function rtwTargetInfo(tr)
%RTWTARGETINFO Target info callback

% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2009/07/27 20:09:54 $

% Register the TFL table for Simulation Targets
% This is to allow MEX targets
% to use MathWorks math library instead of hte compiler's math library
tr.registerTargetInfo(@loc_createTfl);

end

function simTgtTfl = loc_createTfl
simTgtTfl(1) = RTW.TflRegistry('SIM');
simTgtTfl(1).Name = 'Simulation Target TFL';
simTgtTfl(1).TableList = {'simtgt_tfl_table_tmw.mat'};
simTgtTfl(1).BaseTfl = 'ANSI_C';
simTgtTfl(1).TargetHWDeviceType = {'*'};
end
