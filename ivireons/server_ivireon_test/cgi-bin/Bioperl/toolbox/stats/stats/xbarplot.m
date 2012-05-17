function [outliers, h] = xbarplot(data,conf,specs,sigmaest)
%XBARPLOT X-bar chart for monitoring the mean.
%   XBARPLOT(DATA,CONF,SPECS,SIGMAEST) produces an xbar chart of the
%   grouped responses in DATA.  If DATA is a matrix, its rows should be in
%   time order and should contain replicate observations taken at the same
%   time.  If DATA is a timeseries object, the sample at each time should
%   contain replicate observations.
%
%   CONF (optional) is the confidence level of the upper and lower plotted
%   confidence limits. CONF is 0.9973 by default. This means that 99.73% of
%   the plotted points should fall between the control limits if the
%   process is in control.
%
%   SPECS (optional) is a two element vector for the lower and upper
%   specification limits of the response.
%
%   SIGMAEST (optional) specifies how XBARPLOT should estimate sigma.
%   Possible values are 'std' (the default) to use the average
%   within-subgroup standard deviation, 'range' to use the average subgroup
%   range, and 'variance' to use the square root of the pooled variance.
%
%   OUTLIERS = XBARPLOT(DATA,CONF,SPECS,SIGMAEST) returns a vector of
%   indices to the rows where the mean of DATA is out of control.
%
%   [OUTLIERS, H] = XBARPLOT(DATA,CONF,SPECS,SIGMAEST) also returns a
%   vector of handles, H, to the plotted lines.

%   Copyright 1993-2007 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2010/03/16 00:18:31 $

if nargin < 2
   conf = 0.9973;
end

if isempty(conf)
  conf = 0.9973;
end

% For time series data, get raw data and times
[data,ts,samples] = statts2data(data);
[m,n] = size(data);

% Compute sample statistics
xbar  = double(mean(data,2));
avg   = mean(xbar);
if (n < 2)
   error('stats:xbarplot:SubgroupsRequired',...
         'XBARPLOT requires subgroups of at least 2 observations.');
end

% Need a sigma estimate to compute control limits
if (nargin < 4)
   sigmaest = 's';
elseif ((strcmp(sigmaest,'range') || strcmp(sigmaest,'r')) && (n>25))
   error('stats:xbarplot:RangeNotAllowed',...
         ['XBARPLOT cannot use a range estimate if subgroups have' ...
          ' more than 25 observations.']);
end
if (strcmp(sigmaest,'variance') || strcmp(sigmaest,'v'))  % use pooled variance
   s = sqrt(sum(sum(((data - xbar(:,ones(n,1))).^2)))./(m*(n-1)));
elseif (strcmp(sigmaest,'range') || strcmp(sigmaest,'r'))  % use average range
   r = (range(data'))';
   d2 = [0.000 1.128 1.693 2.059 2.326 2.534 2.704 2.847 2.970 3.078 ...
         3.173 3.258 3.336 3.407 3.472 3.532 3.588 3.640 3.689 3.735 ...
         3.778 3.819 3.858 3.895 3.931];
   s = mean(r ./ d2(n));
else                                 % estimate sigma using average s
   svec = (std(data,0,2));
   c4 = exp(gammaln(n/2) - gammaln((n-1)/2) - .5*log((n-1)/2));
   s = mean(svec ./ c4);
end

smult = norminv(1-.5*(1-conf));

delta = double(smult * s ./ sqrt(n));
UCL = avg + delta;
LCL = avg - delta;

incontrol = NaN(1,m);
outcontrol = incontrol;

greenpts = find(xbar > LCL & xbar < UCL);
redpts = find(xbar <= LCL | xbar >= UCL);

incontrol(greenpts) = xbar(greenpts);
outcontrol(redpts) = xbar(redpts);

hh  = plot(samples,xbar,samples,UCL(ones(m,1),:),'r-',samples,avg(ones(m,1),:),'g-',...
           samples,LCL(ones(m,1),:),'r-',samples,incontrol,'b+',...
         samples,outcontrol,'r+');

dx = 0.5 * min(diff(samples));
if any(redpts)
  for k = 1:length(redpts)
     text(samples(redpts(k))+dx,outcontrol(redpts(k)),num2str(redpts(k)));
  end
end

text(samples(m)+dx,UCL,'UCL');
text(samples(m)+dx,LCL,'LCL');
text(samples(m)+dx,avg,'CL');
         
if nargin>=3 && ~isempty(specs)
   set(gca,'NextPlot','add');
   LSL = specs(1);
   USL = specs(2);
   text(samples(m)+dx,USL,'USL');
   text(samples(m)+dx,LSL,'LSL');
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
stattslabelaxes(gca,ts,'','Xbar Chart');

% Make sure all points are visible (must be done after setting tick labels
xlim = get(gca,'XLim');
set(gca,'XLim',[min(xlim(1),samples(1)-2*dx), max(xlim(2),samples(end)+2*dx)]);
