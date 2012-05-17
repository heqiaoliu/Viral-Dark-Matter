function syncPlotInfo(h,varargin)
% Sync the plot display with TsArray data

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2009/03/09 19:23:24 $

if isempty(h.Handles) || isempty(h.Handles.utabPlot) || ...
        ~ishghandle(h.Handles.utabPlot)
    return % No panel
end

%
if isfield(h.Handles,'PlotDataHandles') && all(ishghandle(h.Handles.PlotDataHandles)) &&...
        nargin>=3 && isa(varargin{2},'Simulink.Timeseries')
    I = 1;
    ts0 = varargin{2};
    % valid plot handles already exist
    for k = 1:length(h.SimModelhandle.Members)
        ts = h.SimModelhandle.(h.SimModelhandle.Members(k).name);
        if isa(ts,'Simulink.Timeseries') % Exclude nested tsArrays
            p = h.Handles.PlotDataHandles(I:I+size(ts.Data,2)-1);
            if isequal(ts,ts0)
                time = ts.Time;
                data = ts.Data;
                N = 5000;
                if length(time)>N
                    time1 = time(end-N+1:end);
                    data1 = data(end-N+1:end,:);
                else
                    time1 = time;
                    data1 = data;
                end
                for n = 1:length(p)
                    set(p(n),'Xdata',time1,'Ydata',data1(:,n));
                    %set(get(p(n),'parent'),'xlimmode','auto','ylimmode','auto');
                end
                set(get(p(1),'parent'),'ylimmode','auto',...
                    'xlim',[time1(1),time1(end)+0.02*(time1(end)-time1(1))]);
                %axis(get(p(1),'parent'),'tight')
                break;
            end
            I = I+size(ts.Data,2);
        end
    end
else
    %draw a new plot: sepaprate axes for each timeseries member
    h.Handles.PlotDataHandles = h.plot('separate',h.Handles.utabPlot);
end
