function PID = ctranspose(PID)
% Pertransposition of transfer functions.

%   Author(s): Rong Chen
%   Copyright 2009 MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2010/02/08 22:47:32 $

% s = -s or z = 1/z
PID.Ti = -PID.Ti;
PID.Td = -PID.Td;
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

