function draw(this, Data,varargin)
% Draw method.

%  Author(s): P. Gahinet, C. Buhr
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:21:11 $
hsv = Data.HSV;
nsv = length(hsv);

% Get number of infinite HSV
nns = sum(isinf(hsv));

% Get Y limits
Axes = this.AxesGrid;
Ylims = getylim(Axes,1);

% Stable HSV
idxf = nns+1:nsv;
if isempty(idxf)
    % Setting data to [] has no effect on bar char
    % workaround for (g401115)
    set(this.FiniteSV,'Xdata',nan,'Ydata',nan)
elseif strcmp(Axes.YScale,'linear')
   % Linear scale
   set(this.FiniteSV,'Xdata',idxf,'YData',hsv(idxf))
else
   % Log scale
   hsv(hsv==0) = NaN;
   set(this.FiniteSV,'Xdata',idxf,'YData',hsv(idxf),'BaseValue',eps*Ylims(1))
end
refresh(this.FiniteSV)

% If no stable modes turn off its legend entry
hasbehavior(double(this.FiniteSV),'legend',(~isempty(idxf)))

% Unstable HSV
if nns == 0
    % Setting data to [] has no effect on bar char
    % workaround for (g401115)
    set(this.InfiniteSV,'Xdata',nan,'Ydata',nan)
else
    set(this.InfiniteSV,'Xdata',1:nns,...
        'YData',repmat(2*Ylims(2),1,nns),'BaseValue',eps*Ylims(1))
end
refresh(this.InfiniteSV)

% If no unstable modes turn off its legend entry
hasbehavior(double(this.InfiniteSV),'legend',(nns>0))

hgAxes = getaxes(Axes);
% barseries.refresh messes up with the tick mode
set(hgAxes,'XTickMode','auto')

% Force ticks to be integer
XTicks = get(hgAxes,'XTick');
intXTicks = (XTicks-floor(XTicks))==0;
if ~all(intXTicks)
    % Set ticks to be integers
    set(hgAxes,'Xtick',XTicks(intXTicks));
end