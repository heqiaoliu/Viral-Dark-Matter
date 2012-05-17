function [outliers, h] = schart(data,conf,specs)
%SCHART S chart for monitoring the standard deviation.
%   SCHART(DATA,CONF,SPECS) produces an S chart of the grouped responses in
%   DATA.  If DATA is a matrix, its rows should be in time order and should
%   contain replicate observations taken at the same time.  If DATA is a
%   timeseries object, the sample at each time should contain replicate
%   observations.
%
%   CONF (optional) is the confidence level of the upper and lower plotted
%   confidence limits. CONF is 0.9973 by default. This means that 99.73% of
%   the plotted points should fall between the control limits.
%
%   SPECS (optional) is a two element vector for the lower and upper
%   specification limits of the response.
%
%   OUTLIERS = SCHART(DATA,CONF,SPECS) returns  a vector of indices to the
%   rows where the standard deviation of DATA is out of control.
%
%   [OUTLIERS, H] = SCHART(DATA,CONF,SPECS) also returns a vector of
%   handles, H, to the plotted lines.

%   Reference: Montgomery, Douglas, Introduction to Statistical
%   Quality Control, John Wiley & Sons 1991 p. 235.

%   Copyright 1993-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:17:27 $

if nargin < 2
   conf = 0.9973;
end

if isempty(conf)
  conf = 0.9973;
end
ciprob = 1-(1-conf)/2;

% For time series data, get raw data and times
[data,ts,samples] = statts2data(data);
[m,n] = size(data);
s     = double(std(data,0,2));
sbar  = mean(s);

c4 = exp(gammaln(n/2) - gammaln((n-1)/2) - .5*log((n-1)/2));
cicrit = norminv(ciprob);
b3 = 1 - cicrit*sqrt(1-c4*c4)/c4;
b4 = 1 + cicrit*sqrt(1-c4*c4)/c4;

%chi2crit = chi2inv([(1-conf)/2 1-(1-conf)/2],n-1);
%sigmaci =  sbar*sqrt((n-1)./chi2crit)

LCL = b3*sbar;
if LCL < 0, LCL = 0; end
UCL = b4*sbar;

incontrol = NaN(1,m);
outcontrol = incontrol;

greenpts = find(s > LCL & s < UCL);
redpts = find(s <= LCL | s >= UCL);

incontrol(greenpts) = s(greenpts);
outcontrol(redpts) = s(redpts);

hh  = plot(samples,s,samples,UCL(ones(m,1),:),'r-',samples,sbar(ones(m,1),:),'g-',...
           samples,LCL(ones(m,1),:),'r-',samples,incontrol,'b+',...
         samples,outcontrol,'r+');

dx = 0.5 * min(diff(samples));
if any(redpts)
  for k = 1:length(redpts)
     text(samples(redpts(k))+dx,outcontrol(redpts(k)),num2str(redpts(k)));
  end
end

text(samples(end)+dx,UCL,'UCL');
text(samples(end)+dx,LCL,'LCL');
text(samples(end)+dx,sbar,'CL');
         
if nargin == 3
   set(gca,'NextPlot','add');
   LSL = double(specs(1));
   USL = double(specs(2));
   text(samples(end)+dx,USL,'USL');
   text(samples(end)+dx,LSL,'LSL');
   hh1 = plot(samples,LSL(ones(m,1),:),'g-',samples,USL(ones(m,1),:),'g-');
   set(gca,'NextPlot','replace');
   hh = [hh; hh1];
end

if nargout > 0
  outliers = redpts;
end

if nargout == 2
 h = hh;
end         

set(hh([3 5 6]),'LineWidth',2);

% Label axes, using time series information if any
stattslabelaxes(gca,ts,'Standard Deviation','S Chart');

% Make sure all points are visible (must be done after setting tick labels
xlim = get(gca,'XLim');
set(gca,'XLim',[min(xlim(1),samples(1)-2*dx), max(xlim(2),samples(end)+2*dx)]);
