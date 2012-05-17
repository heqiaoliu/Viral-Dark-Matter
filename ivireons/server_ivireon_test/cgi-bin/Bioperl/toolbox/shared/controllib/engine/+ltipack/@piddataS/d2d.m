function PID2 = d2d(PID1,Ts,options)
% Resample discrete time PID to new sampling interval Ts.

%   Author(s): Rong Chen
%   Copyright 2009-2010 MathWorks, Inc.
%	$Revision: 1.1.8.2.2.1 $  $Date: 2010/06/24 19:43:17 $
try
   % Note: Retain the original formulas
   if any(strncmp(options.Method,'t',1))
      PID2 = pidstd(d2d(zpk(PID1),Ts,options),PID1);
   else
      PID2 = pidstd(d2d(ss(PID1),Ts,options),PID1);
   end
catch ME
   throw(ME)
end