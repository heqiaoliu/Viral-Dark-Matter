function [xlim, ylim] = thispassbandzoom(this, fcns, Hd, hfm)
%THISPASSBANDZOOM   Returns the limits of the passband zoom.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/05/23 08:15:10 $

% Get the mask information from the subclass.
[f, a] = getmask(this, fcns);

% Get the limits from the mask.
xlim_specified = [f(3) fcns.getfs()/2];
ylim_specified = [a(5) a(4)];

% Calculate the dynamic range of the ylimits.

% If there is no dynamic range in the specifications, try the measurements.
if ~isempty(Hd)
    
    m = measure(Hd);
    if isempty(m.Apass)
        m = measure(Hd, 'Fpass', m.F3dB);
    end
    
    [f, a] = getmask(this, fcns, Hd.nominalgain, m);
    xlim_measured = [f(3) fcns.getfs()/2];
    ylim_measured = [a(5) a(4)];

    if xlim_measured(1) > xlim_specified(1)
        xlim = xlim_measured;
    else
        xlim = xlim_specified;
    end
    
    % If the measured Apass is greater than that 
    if ylim_measured(2) > ylim_specified(2) || ...
            diff(ylim_specified) == 0
        ylim = ylim_measured;
    else
        ylim = ylim_measured;
    end
    
else
    xlim = xlim_specified;
    ylim = ylim_specified;
end

% Calculate the dynamic range of the xlimits.
dr_xlim = diff(xlim);
dr_ylim = diff(ylim);

% Add padding to the xlimits based on the dynamic range.
xlim(1) = xlim(1)-dr_xlim/10;

% Add some buffer to the ylimits.
% ylim = [ylim(1)-dr_ylim/10 ylim(2)+dr_ylim/10];
% ylim = ylim + [-1 1]*dr_ylim/10;

% [EOF]
