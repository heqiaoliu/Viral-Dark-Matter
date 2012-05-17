function h = normplot(x)
%NORMPLOT Displays a normal probability plot.
%   H = NORMPLOT(X) makes a normal probability plot of the data in X. For
%   matrix, X, NORMPLOT displays a plot for each column. H is a handle to the
%   plotted lines.
%   
%   The purpose of a normal probability plot is to graphically assess whether
%   the data in X could come from a normal distribution. If the data are
%   normal the plot will be linear. Other distribution types will introduce
%   curvature in the plot. NORMPLOT uses midpoint probability plotting
%   positions. Use PROBPLOT when the data included censored observations.
%
%   Use the data cursor to read precise values, observation numbers, and  
%   the value of the observations projected on to the reference line. 
%
%   See also PROBPLOT, WBLPLOT.

%   Copyright 1993-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:16:32 $

if size(x,1)==1
    x = x';
end
[n, m] = size(x);

[sx,originds] = sort(x);

minx  = min(sx(:));
maxx  = max(sx(:));
if isnan(minx) % Data all NaNs, setting arbitrary limits.
    minx = 0;
    maxx = 1;
end
range = maxx-minx;

if range>0
  minxaxis  = minx-0.025*range;
  maxxaxis  = maxx+0.025*range;
else
  minxaxis  = minx - 1;
  maxxaxis  = maxx + 1;
end

% Use the same Y vector if all columns have the same count.
if (~any(isnan(x(:))))
   eprob = ((1:n)' - 0.5)./n;
else
   nvec = sum(~isnan(x));
   eprob = repmat((1:n)', 1, m);
   eprob = (eprob-.5) ./ repmat(nvec, n, 1);
   eprob(isnan(sx)) = NaN;
end
   
y  = norminv(eprob,0,1);

minyaxis  = norminv(0.25 ./n,0,1);
maxyaxis  = norminv((n-0.25) ./n,0,1);


p     = [0.001 0.003 0.01 0.02 0.05 0.10 0.25 0.5...
         0.75 0.90 0.95 0.98 0.99 0.997 0.999];

label = {'0.001','0.003', '0.01','0.02','0.05','0.10','0.25','0.50', ...
         '0.75','0.90','0.95','0.98','0.99','0.997', '0.999'};

tick  = norminv(p,0,1);

q1x = prctile(x,25);
q3x = prctile(x,75);
q1y = prctile(y,25);
q3y = prctile(y,75);
qx = [q1x; q3x];
qy = [q1y; q3y];


dx = q3x - q1x;
dy = q3y - q1y;
slope = dy./dx;
centerx = (q1x + q3x)/2;
centery = (q1y + q3y)/2;
maxx = max(x);
minx = min(x);
maxy = centery + slope.*(maxx - centerx);
miny = centery - slope.*(centerx - minx);
yinter = centery - slope.*(centerx);

mx = [minx; maxx];
my = [miny; maxy];


% Plot data and corresponding reference lines in the same color,
% following the default color order.  Plot reference line first, 
% followed by the data, so that data will be on top of reference line.
newplot();
hrefends = line(mx,my,'LineStyle','-.','Marker','none');
hrefmid = line(qx,qy,'LineStyle','-','Marker','none');
hdat = line(sx,y,'LineStyle','none','Marker','+');
if m==1
    set(hdat,'MarkerEdgeColor','b');
    set([hrefends,hrefmid],'Color','r');
end
if nargout>0
    h = [hdat;hrefmid;hrefends];
end


set(gca,'YTick',tick,'YTickLabel',label);
set(gca,'YLim',[minyaxis maxyaxis],'XLim',[minxaxis maxxaxis]);
xlabel('Data');
ylabel('Probability');
title('Normal Probability Plot');

grid on;


for i=1:m
    % Set custom data cursor on data.
    hB = hggetbehavior(hdat(i),'datacursor');
    set(hB,'UpdateFcn',{@normplotDatatipCallback,slope(i),yinter(i)});
    % Disable datacursor on reference lines.
    hB = hggetbehavior(hrefends(i),'datacursor');
    set(hB,'Enable',false);
    hB = hggetbehavior(hrefmid(i),'datacursor');
    set(hB,'Enable',false);
    if m>1
        setappdata(hdat(i),'group',i);
    end
    setappdata(hdat(i),'originds',originds(:,i));
end

% ----------------------------
function datatipTxt = normplotDatatipCallback(obj,evt,slope,yinter)

target = get(evt,'Target');
ind = get(evt,'DataIndex');
pos = get(evt,'Position');

x = pos(1);
y = pos(2);

% Compute position to display.
yper = normcdf(y,0,1);
yperexp = normcdf(polyval([slope,yinter],x));
xexp = polyval([1/slope,-yinter/slope],y);

% Get the original row number of the selected point.
originds = getappdata(target,'originds');
origind = originds(ind);

% Get the group number, which is set if more than one.
group = getappdata(target,'group');
 
% Generate text to display.
datatipTxt = {
    ['Data: ',num2str(x)],...
    ['Probability: ',num2str(yper)],...
    ''
    };
datatipTxt{end+1} = ['Observation: ',num2str(origind)];
if ~isempty(group)
    datatipTxt{end+1} = ['Group: ',num2str(group)];
end

datatipTxt{end+1} = '';
datatipTxt{end+1} = ['Refline Data: ',num2str(xexp)];
datatipTxt{end+1} = ['Refline Probability: ',num2str(yperexp)];
