function h = ewmaplot(data,lambda,alpha,specs)
%EWMAPLOT Exponentially weighted moving average chart.
%   H = EWMAPLOT(DATA,LAMBDA,ALPHA,SPECS) produces an EWMA chart of the
%   grouped responses in DATA.  If DATA is a matrix, its rows should be in
%   time order and should contain replicate observations taken at the same
%   time.  If DATA is a timeseries object, the sample at each time should
%   contain replicate observations.
%
%   LAMBDA (optional) is the parameter that controls how much the current
%   prediction is influenced by past observations. Higher values of LAMBDA
%   give less weight to past observations and more weight to the current
%   observation.  By default, LAMBDA = 0.4, and LAMBDA must be between 0
%   and 1. 
%
%   ALPHA (optional) is the significance level of the upper and lower
%   plotted confidence limits. ALPHA is 0.0027 by default. This means that
%   99.73% of the plotted points should fall between the control limits if
%   the process is in control.
%
%   SPECS (optional) is a two element vector for the lower and upper
%   specification limits of the response.
%
%   H is a vector of handles to the plotted lines.

%   Reference: Montgomery, Douglas, Introduction to Statistical
%   Quality Control, John Wiley & Sons 1991 p. 299.

%   Copyright 1993-2007 The MathWorks, Inc.  
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:13:36 $ 
 

if nargin < 3
   alpha = 0.0027;
end

if nargin < 2
   lambda = 0.4;
end

if isempty(alpha)
  alpha = 0.0027;
end

if isempty(lambda)
   lambda = 0.4;
end

if lambda < 0 || lambda > 1
   error('stats:ewmaplot:BadLambda',...
         'LAMBDA must be a scalar between 0 and 1.');
end
if alpha <= 0 || alpha >= 1
   error('stats:ewmaplot:BadAlpha','ALPHA must be a scalar between 0 and 1.');
end
ciprob = 1-alpha/2;

% For time series data, get raw data and times
[data,ts,samples] = statts2data(data);
[m,n] = size(data);
if n == 1
   xbar = data;
else
   xbar  = mean(data,2);
end

avg   = double(mean(xbar));
z     = filter(lambda,[1 (lambda - 1)],xbar,(1-lambda)*avg);

if (n > 1)
   sbar  = mean(std(data,0,2));
   c4 = exp(gammaln(n/2) - gammaln((n-1)/2) - .5*log((n-1)/2));
   s = mean(sbar ./ c4);
else
   s = Inf;
end

smult = norminv(ciprob);

lambdacoef = sqrt(lambda./((2-lambda).*n));
UCL = double(avg + smult*s*lambdacoef);
LCL = double(avg - smult*s*lambdacoef);

incontrol = NaN(1,m);
outcontrol = incontrol;

greenpts = find(z > LCL & z < UCL);
redpts = find(z <= LCL | z >= UCL);

incontrol(greenpts) = z(greenpts);
outcontrol(redpts) = z(redpts);

hh  = plot(samples,z,samples,UCL(ones(m,1),:),'b-',...
           samples,avg(ones(m,1),:),'r-',...
           samples,LCL(ones(m,1),:),'b-',samples,incontrol,'b+',...
         samples,outcontrol,'r+');

dx = 0.5 * min(diff(samples));
if any(redpts)
  for k = 1:length(redpts)
     text(samples(redpts(k))+dx, outcontrol(redpts(k)),num2str(redpts(k)));
  end
end

text(samples(m)+dx,UCL,'UCL');
text(samples(m)+dx,LCL,'LCL');
text(samples(m)+dx,avg,'CL');
         
if nargin == 4
   set(gca,'NextPlot','add');
   LSL = double(specs(1));
   USL = double(specs(2));
   text(samples(m)+dx, USL,'USL');
   text(samples(m)+dx, LSL,'LSL');
   hh1 = plot(samples,LSL(ones(m,1),:),'g-',samples,USL(ones(m,1),:),'g-');
   set(gca,'NextPlot','replace');
   hh = [hh; hh1];
end

if nargout == 1
   h = hh;
end         

set(hh(3),'LineWidth',2);

% Label axes, using time series information if any
stattslabelaxes(gca,ts,'EWMA','Exponentially Weighted Moving Average (EWMA) Chart');

% Make sure all points are visible (must be done after setting tick labels
xlim = get(gca,'XLim');
set(gca,'XLim',[min(xlim(1),samples(1)-2*dx), max(xlim(2),samples(end)+2*dx)]);
