function PID = ctranspose(PID)
% Pertransposition of transfer functions.

%   Author(s): Rong Chen
%   Copyright 2009 MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2010/02/08 22:47:26 $

% s = -s or z = 1/z
PID.Ki = -PID.Ki;
PID.Kd = -PID.Kd;
PID.Tf = -PID.Tf;
if PID.Ts~=0
    if PID.IFormula=='F'
        PID.IFormula = 'B';
    elseif PID.IFormula=='B'
        PID.IFormula = 'F';
    end
    if PID.DFormula=='F'
        PID.DFormula = 'B';
    elseif PID.DFormula=='B'
        PID.DFormula = 'F';
    end
    % no change is needed for 'Trapezoidal'    
end

