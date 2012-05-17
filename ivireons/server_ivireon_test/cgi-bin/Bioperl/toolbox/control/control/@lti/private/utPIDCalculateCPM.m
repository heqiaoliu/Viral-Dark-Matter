function val = utPIDCalculateCPM(CPM,sys)
% Singular frequency based P/PI/PID/PIDF Tuning sub-routine
%
%   This function computes controller performance in time domain.
%

%   Author(s): Rong Chen
%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:31:13 $

% compute step response
[y,t] = step(sys);
% get error 
Error = 1 - y;
% compute performance index
switch CPM
    case 'IAE'
        PI = sum(abs(Error(1:end-1)).*diff(t));
    case 'ISE'
        PI = sum(Error(1:end-1).^2.*diff(t));
    case 'ITAE'
        PI = sum(abs(Error(1:end-1)).*t(1:end-1).*diff(t));
    case 'ITSE'
        PI = sum(Error(1:end-1).^2.*t(1:end-1).*diff(t));
end
% return PI as well as the last sample in step response
val = [PI Error(end) t(end)];
