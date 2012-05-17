%SLDEMO_ABSBRAKEPLOTS 
%   plots the results from SLDEMO_ABSBRAKE model simulation
%
%   See also SLDEMO_ABSBRAKE, SLDEMO_ABSDATA
%

%   Author(s): L. Michaels, S. Quinn, 12/01/97 
%   Edited   : G. Chistol,            08/04/06
%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $

h = findobj(0, 'Name', 'ABS Speeds');
if isempty(h),
  h=figure('Position',[26   239   452   257],...
           'Name','ABS Speeds',...
           'NumberTitle','off');
end

figure(h)
set(h,'DefaultAxesFontSize',8)

% data is logged in sldemo_absbrake_output
% this prevents the main workspace from getting cluttered

% plot wheel speed and car speed
plot(sldemo_absbrake_output.yout.Vs.Time, sldemo_absbrake_output.yout.Vs.Data, ...
     sldemo_absbrake_output.yout.Ww.Time, sldemo_absbrake_output.yout.Ww.Data);
legend('Vehicle Speed \omega_v','Wheel Speed \omega_w','Location','best'); 
title('Vehicle speed and wheel speed'); ylabel('Speed(rad/sec)'); xlabel('Time(sec)');

h = findobj(0, 'Name', 'ABS Slip');
if isempty(h),
  h=figure('Position',[486    239   452   257],...
           'Name','ABS Slip',...
           'NumberTitle','off');
end

figure(h);
plot(sldemo_absbrake_output.slp.Time,sldemo_absbrake_output.slp.Data);
title('Slip'); xlabel('Time(sec)'); ylabel('Normalized Relative Slip');
