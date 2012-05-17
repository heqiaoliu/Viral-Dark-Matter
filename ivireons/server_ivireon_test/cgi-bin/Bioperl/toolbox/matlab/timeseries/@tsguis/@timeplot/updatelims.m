function updatelims(this)
%UPDATELIMS  Limit picker for time plots.
%
%   UPDATELIMS(H) computes:
%     1) an adequate X range from the data or source
%     2) common Y limits across rows for axes in auto mode.

%  Copyright 1986-2006 The MathWorks, Inc.
%  $Revision: 1.1.6.6 $ $Date: 2007/05/29 21:16:27 $

AxesGrid = this.AxesGrid;
% Update X range by merging time Focus of all visible data objects.
% RE: Do not use SETXLIM in order to preserve XlimMode='auto'
% REVISIT: make it unit aware
ax = getaxes(this);
AutoX = strcmp(AxesGrid.XLimMode,'auto');
if any(AutoX)
   set(ax(:,AutoX),'Xlim', getfocus(this));
end

if strcmp(AxesGrid.YNormalization,'on')
   % Reset auto limits to [-1,1] range
   set(ax(strcmp(AxesGrid.YLimMode,'auto'),:),'Ylim',[-1.1 1.1])
else
   % Update Y limits
   AxesGrid.updatelims('manual', [])
end


%% Get time extent
xlims = AxesGrid.getxlim{1};
S = warning('off','all');
for k=1:length(this.Waves)
    tinfo = this.Waves(k).DataSrc.Timeseries.TimeInfo;
    unitconvfact = tsunitconv(this.TimeUnits,tinfo.Units);
    startTime = tinfo.Start*unitconvfact;
    endTime = tinfo.End*unitconvfact;
    if ~isempty(this.Waves(k).Data.Time) 
        if  strcmp(this.AbsoluteTime,'on') && ...
                ~isempty(tinfo.StartDate)
            refabstime = (datenum(tinfo.StartDate) - ...
                datenum(this.StartDate))*tsunitconv(this.TimeUnits,'days');
            startTime = startTime+refabstime;
            endTime = endTime+refabstime;
        else
            refabstime = 0;
        end
        
        if (startTime<this.Waves(k).Data.Time(1) && this.Waves(k).Data.Time(1)>xlims(1)) || ...
           (endTime>this.Waves(k).Data.Time(end)&& this.Waves(k).Data.Time(end)<xlims(2))
            this.Waves(k).DataSrc.send('sourcechange')
        end
    end  
end
warning(S);
localUpdateXticks(this)

if ~isempty(this.PropEditor)
    this.updatetime(this.PropEditor);
    this.PropEditor.axespanel(this,'Y');
    this.updatechartable(this.PropEditor);
end

function localUpdateXticks(h)

%% Get the axes
ax = h.getaxes;

%% Figure resize callback which modifes the default ticks to datestrs when
%% the time vector is absolute

% Absolute time vector or formatted relative time
if strcmp(h.Absolutetime,'on')
    if ~isempty(h.TimeFormat) && tsIsDateFormat(h.TimeFormat)
        timeFormat = h.TimeFormat;
    else
        timeFormat = 'dd-mmm-yyyy HH:MM:SS';
    end

    % Use the first axes to estimate the number of date labels which will
    % fit  
    pixelsize = getpixelposition(h.Axesgrid.Parent).*get(ax(1),'Position');
    Hfontsize = h.axesgrid.axesstyle.Fontsize/2; 
    labelwidth = (length(timeFormat)+2)*Hfontsize;
    numlabels = pixelsize(3)/labelwidth;
    
    % Create time vector of datestrs
    t = linspace(h.Axesgrid.getxlim{1}(1),h.Axesgrid.getxlim{1}(2),...
        numlabels);
    
    % Try not to shift the ticks during a pan, since it gives the
    % appearance that the new pan position is not being honored.
    xtick1 = get(ax(1),'xtick');
    if t(1)>=xtick1(1) && t(1)<=xtick1(end)
        [junk,ind] = min(abs(t(1)-xtick1));
        t = t-t(1)+xtick1(ind);
    end
    tstr = datestr(datenum(h.StartDate)+tsunitconv('days',h.TimeUnits)*t,...
          timeFormat);

    % Overwrite the xticks with the new labels
    set(ax(end),'xticklabel',tstr,'xtick',t);
else
   set(ax(end),'xTickMode','auto')
   set(ax(end),'xTickLabelMode','auto')
end