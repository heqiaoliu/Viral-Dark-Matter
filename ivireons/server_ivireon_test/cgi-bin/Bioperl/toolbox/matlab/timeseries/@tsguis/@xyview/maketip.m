function str = maketip(this,tip,info)
%MAKETIP  Build data tips for @xyview curves.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

%   Author(s):  
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2005/12/15 20:58:36 $

r = info.Carrier;
AxGrid = info.View.AxesGrid;

% Clear all data tips on this line
dcm = datacursormode(ancestor(AxGrid.Parent,'figure'));
dc = dcm.DataCursors;
hosts = get(dc,{'Host'});
for j=1:length(hosts)
    if dc(j)~=tip
        dcm.removeDataCursor(dc(j));
    end
end

% Ensure zstackminimum is set to at least 10 in case this tip was created 
% with hg
set(tip,'zstackminimum',11,'EnableZStacking',true);

pos = tip.getCursorInfo.Position;
if ~isempty(pos)
    xdata = get(tip.Host,'xdata');
    ydata = get(tip.Host,'ydata');
    z = abs(ones(numel(xdata),1)*pos(1:2)-[xdata(:) ydata(:)]);
    [junk,I] = min(z(:,1).^2+z(:,2).^2);
    if ~isempty(I)
        if ~isempty(r.DataSrc.Timeseries.TimeInfo.StartDate)
            unitconv1 = tsunitconv('days',r.DataSrc.Timeseries.TimeInfo.Units);
            time1 = datestr(r.DataSrc.Timeseries.Time(I(1))*unitconv1+...
                datenum(r.DataSrc.Timeseries.TimeInfo.StartDate));         
            str{1,1} = sprintf('Time in %s: %s',r.DataSrc.Timeseries.Name,...
                time1);
        else
            str{1,1} = sprintf('Time in %s: %0.3g',r.DataSrc.Timeseries.Name,...
                r.DataSrc.Timeseries.Time(I(1)));
        end
        if ~isempty(r.DataSrc.Timeseries2.TimeInfo.StartDate)
            unitconv2 = tsunitconv('days',r.DataSrc.Timeseries2.TimeInfo.Units);
            time2 = datestr(r.DataSrc.Timeseries2.Time(I(1))*unitconv2+...
                datenum(r.DataSrc.Timeseries2.TimeInfo.StartDate));         
            str{1,2} = sprintf('Time in %s: %s',r.DataSrc.Timeseries2.Name,...
                time2);
        else
            str{1,2} = sprintf('Time in %s: %0.3g',r.DataSrc.Timeseries2.Name,...
                r.DataSrc.Timeseries2.Time(I(1)));
        end

    else
        str = '';
    end
else
    str = '';
end

