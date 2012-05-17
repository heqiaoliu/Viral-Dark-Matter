function holdXAxisLimits(ntx,hold)
% Set x-axis display limits to manual mode
% Axis will stop autoscaling.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:21:23 $

if nargin<2, hold=true; end
if hold
    % Hold mode
    % Set local x-axis min/max limits, which puts local mode to manual
    % 
    % We display limits that are +/-1 larger than needed
    % So when we convert the displayed xlim limits to new local limits,
    % we must subtract +/-1 from the limits we see.
    %
    % Make sure xlimits are integers
    xlim = get(ntx.hHistAxis,'xlim');
    xmin = floor(xlim(1)+1);
    xmax = ceil(xlim(2)-1);
    setXAxisLimits(ntx,xmin,xmax); % resets .XAxisAutoscaling
else
    % When un-holding limits, limits are recomputed automatically
    ntx.XAxisAutoscaling = true;
    updateXTickLabels(ntx);
end
showOutOfRangeBins(ntx); % update to be vis or invis
