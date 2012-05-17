function out = plot(node,host)
%PLOT the Simulink time series data. Events are not annotated.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $


out = [];
h = node.Timeseries;
ax = axes('parent',host);
p = get(ax,'pos');
set(ax,'pos',[p(1:3),p(4)*0.9]);

%% If a length limit is supplied plot no more than the specified number points
time = h.Time;
data = h.Data;
if length(time)>5000
    time1 = time(end-5000+1:end);
    data1 = data(end-5000+1:end,:);
else
    time1 = time;
    data1 = data;
end

%% Annotate and plot
out = plot(ax, time1, data1);
title(ax,h.Name,'Interpreter','none');
xlabel(ax,'Time','Interpreter','none');
if ~isempty(time1)
    set(ax,'xlim',[time1(1),time1(end)+max(eps(time1(end)),0.02*(time1(end)-time1(1)))]);
end
