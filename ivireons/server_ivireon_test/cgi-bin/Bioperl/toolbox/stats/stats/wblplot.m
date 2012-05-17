function h = wblplot(x)
%WBLPLOT Weibull probability plot.
%   H = WBLPLOT(X) displays a Weibull probability plot of the data in X. For
%   matrix, X, WBLPLOT displays a plot for each column. H is a handle to the
%   plotted lines.
%   
%   The purpose of a Weibull probability plot is to graphically assess whether
%   the data in X could come from a Weibull distribution. If the data are
%   Weibull the plot will be linear. Other distribution types will introduce
%   curvature in the plot. WBLPLOT uses midpoint probability plotting
%   positions. Use PROBPLOT when the data included censored observations.
%
%   Use the data cursor to read precise values, observation numbers, and  
%   the value of the observations projected on to the reference line. 
%
%   See also PROBPLOT, NORMPLOT.

%   Copyright 1993-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:18:18 $

if size(x,1)==1
    x = x';
end
[n, m] = size(x);

[sx originds]= sort(x);
minx  = min(sx(:));
maxx  = max(sx(:));
if isnan(minx) % Data all NaNs, setting arbitrary limits.
    minx = 1;
    maxx = 10;
end
range = maxx-minx;

if range > 0
  minxaxis  = 0;
  maxxaxis  = maxx+0.025*range;
else
  minxaxis  = minx - 1;
  maxxaxis  = maxx + 1;
end

% Use the same Y vector if all columns have the same count
if (~any(isnan(x(:))))
   eprob = ((1:n)' - 0.5)./n;
else
   nvec = sum(~isnan(x));
   eprob = repmat((1:n)', 1, m);
   eprob = (eprob-.5) ./ repmat(nvec, n, 1);
   eprob(isnan(sx)) = NaN;
   n = max(nvec);  % sample size for setting axis limits
end
y  = log(log(1./(1-eprob)));
if (size(y,2) < m)
   y = y(:, ones(1,m));
end
if n>0
    minyaxis  = log(log(1./(1 - 0.25 ./n)));
    maxyaxis  = log(log(1./(0.25 ./n)));
else
    minyaxis = -4; % Data all NaNs, setting arbitrary limits.
    maxyaxis = 1;
end


p     = [0.001 0.003 0.01 0.02 0.05 0.10 0.25 0.5...
         0.75 0.90 0.96 0.99 0.999];

label = {'0.001','0.003', '0.01','0.02','0.05','0.10','0.25','0.50', ...
         '0.75','0.90','0.96','0.99', '0.999'};

tick  = log(log(1./(1-p)));

q1x = prctile(x,25);
q3x = prctile(x,75);
q1y = prctile(y,25);
q3y = prctile(y,75);

qx = [q1x; q3x];
qy = [q1y; q3y];

b = zeros(m,2);
mx = [minx maxx];
mx = mx(ones(m,1),:);
my = zeros(m,2);

for k = 1:m
   b(k,:) = polyfit(log(qx(:,k)),qy(:,k),1);
   my(k,:) = polyval(b(k,:),log(mx(k,:)));
end
mx = mx';
my = my';

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

for i=1:m
    % Set custom data cursor on data
    hB = hggetbehavior(hdat(i),'datacursor');
    set(hB,'UpdateFcn',{@wblplot_datatip_callback,b(i,:)});
    % Disable datacursor on reference lines
    hB = hggetbehavior(hrefends(i),'datacursor');
    set(hB,'Enable',false);
    hB = hggetbehavior(hrefmid(i),'datacursor');
    set(hB,'Enable',false);
    if m>1
        setappdata(hdat(i),'group',i);
    end
    if ~isempty(originds)
        setappdata(hdat(i),'originds',originds(:,i));
    end
end

set(gca,'YTick',tick,'YTickLabel',label,'XScale','log');
set(gca,'YLim',[minyaxis maxyaxis],'XLim',[minxaxis maxxaxis]);
xlabel('Data');
ylabel('Probability');
title('Weibull Probability Plot');

grid on;

% ----------------------------
function datatip_txt = wblplot_datatip_callback(obj,evt,b)

target = get(evt,'Target');
ind = get(evt,'DataIndex');
pos = get(evt,'Position');

x = pos(1);
y = pos(2);

% Compute position to display.
yper = 1-1./exp(exp(y));
yperexp = 1-1./exp(exp(polyval(b,log(x))));
xexp = exp(polyval([1/b(1),-b(2)/b(1)],y));

% Get the original row number of the selected point.
originds = getappdata(target,'originds');
origind = originds(ind);

% Get the group number, which is set if more than one.
group = getappdata(target,'group');
 
% Generate text to display.
datatip_txt = {
    ['Data: ',num2str(x)],...
    ['Probability: ',num2str(yper)],...
    ''
    };
datatip_txt{end+1} = ['Observation: ',num2str(origind)];
if ~isempty(group)
    datatip_txt{end+1} = ['Group: ',num2str(group)];
end

datatip_txt{end+1} = '';
datatip_txt{end+1} = ['Refline Data: ',num2str(xexp)];
datatip_txt{end+1} = ['Refline Probability: ',num2str(yperexp)];






