function xlab = getXLabel(this,xlab)
% get xlabel for time or freq plots
% xlab: 'Time' or 'Frequency'

% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2009/03/09 19:14:27 $

%tu = this.TimeUnits;
L = length(this.ModelData);
tu = cell(L,1);
for k = 1:L
    tu{k} = this.ModelData(k).Model.TimeUnit;
end

tu(cellfun('isempty',tu)) = []; % remove empty
tu = unique(tu);

isTime = strcmpi(xlab,'time');
if isempty(tu)
    if isTime
        xlab = [xlab,' (s)'];
    else
        xlab = [xlab,' (rad/s)'];
    end
elseif length(tu)==1 %unit units
    if isTime
        xlab = [xlab,' (',tu{1},')'];
    else
        xlab = [xlab,' (rad/',tu{1},')'];
    end
end

