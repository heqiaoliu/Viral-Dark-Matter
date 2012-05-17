function h = probplot(varargin)
%PROBPLOT Probability plot
%   PROBPLOT(Y) produces a normal probability plot comparing the distribution
%   of the data Y to the normal distribution.  Y can be a single vector, or
%   a matrix with a separate sample in each column. The plot includes a
%   reference line that passes through the lower and upper quartiles of
%   Y, and that is useful for judging whether the data follow a normal
%   distribution. PROBPLOT uses midpoint probability plotting positions.
%
%   PROBPLOT('DISTNAME',Y) creates a probability plot for the specified
%   distribution.  DISTNAME is a character string chosen from the following
%   list of distributions:
%
%       'exponential'                      Exponential
%       'extreme value' or 'ev'            Extreme value
%       'lognormal'                        Lognormal
%       'normal'                           Normal
%       'rayleigh'                         Rayleigh
%       'weibull' or 'wbl'                 Weibull
%
%   PROBPLOT(Y,CENS,FREQ) or PROBPLOT('DISTNAME',Y,CENS,FREQ) requires
%   a vector Y.  CENS is a vector of the same size as Y and contains
%   1 for observations that are right-censored and 0 for observations
%   that are observed exactly.  FREQ is a vector of the same size as Y,
%   containing integer frequencies for the corresponding elements in Y.
%
%   PROBPLOT(AX,Y) takes a handle AX to an existing probability plot, and
%   adds additional lines for the samples in Y.  AX is a handle for a
%   set of axes.
%
%   Use the data cursor to read precise values from the plot, as well as
%   observation numbers from the points when CENS and FREQ are left
%   unspecified.
%
%   PROBPLOT(...,'noref') omits the reference line.
%
%   PROBPLOT(AX,PD) takes a probability distribution object PD, and adds a
%   fitted line to the axes specified by AX to represent the probability
%   distribution specified by PD.
%
%   PROBPLOT(AX,FUN,PARAMS) takes a function FUN and a set of parameters
%   PARAMS, and adds a fitted line to the axes specified by AX.  FUN is
%   a function to compute a cdf function, and is specified with @
%   (such as @weibcdf).  PARAMS is the set of parameters required to
%   evaluate FUN, and is specified as a cell array or vector.  The
%   function must accept a vector of X values as its first argument,
%   then the optional parameters, and must return a vector of cdf
%   values evaluated at X.
%
%   H=PROBPLOT(...) returns handles to the plotted lines.
%
%   The y axis scale is based on the selected probability distribution. The
%   x axis has a log scale for the Weibull and lognormal distributions, and
%   a linear scale for the others.  The Ith sorted value from a sample of
%   size N is plotted against the midpoint in the jump of the empirical CDF
%   on the y axis.  With uncensored data, that midpoint is (I-0.5)/N.  With
%   censored data, the y value is more complicated to compute.
%
%   Example:  Generate exponential data.  A normal probability plot does
%             not show a good fit.  A Weibull probability plot looks
%             better, because the exponential distribution is part of the
%             Weibull family of distributions.
%       y = exprnd(5,200,1);
%       probplot(y);                      % normal probability plot
%       figure; probplot('weibull',y);    % Weibull probability plot
%
%   See also NORMPLOT, WBLPLOT, ECDF.

%   Copyright 2003-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2010/05/10 17:59:17 $

% Check for a special flag at the end to skip reference lines
if nargin>0 && isequal(varargin{end},'noref')
    addrefline = false;
    varargin(end) = [];
else
    addrefline = true;
end

% Now check number of arguments, possibly after removing flag
error(nargchk(1,Inf,nargin,'struct'));

% Get probability distribution info from input name, input handle, or default
[hAxes,newdist,dist,param,varargin] = getdistname(varargin);
if length(dist)~=1
    error('stats:probplot:InvalidDistribution','Invalid distribution name.');
end

% Get some properties of this distribution
distname = dist.name;
distcode = dist.code;
if dist.uselogpp
    invcdffunc = @(x,varargin) log(feval(dist.invfunc,x,varargin{:}));
    cdffunc = @(x,varargin) feval(dist.cdffunc,exp(x),varargin{:});
else
    invcdffunc = dist.invfunc;
    cdffunc = dist.cdffunc;
end

% Plot either a data sample or a user-supplied fit
if isempty(varargin)
    % Just setting up empty plot
    x = [];
    addfit = false;
elseif isnumeric(varargin{1})
    % Plot the sample or samples in X
    [x,cens,freq,originds] = checkdata(dist,varargin{:});
    addfit = false;
elseif isequal(class(varargin{1}),'function_handle') ...
        || ischar(varargin{1}) ...
        || isa(varargin{1},'ProbDist')
    % Must be plotting a fit rather than a data sample
    x = [];
    addfit = true;
    if isa(varargin{1},'ProbDist')
        fitcdffunc = @(x) cdf(varargin{1},x);
        param = {};
    else
        fitcdffunc = varargin{1};
        if length(varargin)>=2
            if iscell(varargin{2})
                param = varargin{2};
            else
                param = num2cell(varargin{2});
            end
        end
    end
else
    error('stats:probplot:InvalidData','Invalid Y or FUN argument.')
end

% Create probability plot of the proper type
if newdist
    hAxes = createprobplot(hAxes,distcode,distname,param,dist,...
                                 cdffunc,invcdffunc);
end

% Plot a data sample
hfit = [];
href = [];
hdata = [];
if ~isempty(x)
    % Get plotting positions and expanded x data vector for plot
    [xData,ppos] = getppos(x,cens,freq);

    % Draw fit lines first, so they will be below the data points
    if addrefline
        % Add lines representing fits
        nsamples = size(xData,2);
        samplenum = zeros(nsamples,1);
        for j=1:nsamples
           % Get some points on the reference line
           if isempty(cens) && isempty(freq)
              probpoints = [];
           else
              probpoints = ppos;
           end
           refxy = getrefxy(xData(:,j),probpoints,...
                            invcdffunc,param,dist.uselogpp);

           if ~isempty(refxy)
              % Create a function that will put a line through these points
              %      A = y1 - x1*(y2-y1)/(x2-x1)
              %      B = (y2-y1)/(x2-x1)
              B = (refxy(2,2)-refxy(1,2)) ./ (refxy(2,1)-refxy(1,1));
              A = refxy(1,2) - refxy(1,1) .* B;
              if dist.uselogpp
                 % The reference x1 and x2 values are already on the log scale
                 linefun = @(x)(A+B*log(x));
              else
                 linefun = @(x)(A+B*x);
              end

              % Create a reference line based on this function
              if feature('HGUsingMATLABClasses')
                 hrefj = specgraphhelper('createFunctionLineUsingMATLABClasses',...
                     'Function',linefun,'Parent',hAxes);
              else
                 hrefj = double(graph2d.functionline(linefun, ...
                    'Parent',hAxes));
              end
              href = [href; hrefj];
              samplenum(numel(href)) = j;
              
              % Add custom data cursor
              hB = hggetbehavior(hrefj,'datacursor');
              set(hB,'UpdateFcn',{@probplotDatatipCallback,hAxes});
              if nsamples>1
                  setappdata(hrefj,'group',j);
              end

              % Start off with reasonable default properties
              set(hrefj,'XLimInclude','off','YLimInclude','off',...
                          'Color','k','LineStyle','--','Tag','reference');
           end
        end
    end
    
    % Plot data points
    hdata = adddatapoints(hAxes,xData,ppos,originds);

    if addrefline && nsamples>1
        % With multiple samples, make sure fit color matches data color
        for j=1:numel(href)
            set(href(j),'Color',get(hdata(samplenum(j)),'Color'));
        end
    end
end

% Add a fit
if addfit
    hfit = ppaddfit(hAxes,fitcdffunc,param);
end

% Now that y limits are established, define good y tick positions and labels
setprobticks(hAxes);

if nargout>0
   h = [hdata(:); href(:); hfit(:)];
end

% -------------------------------------
function hAxes = createprobplot(hAxes,dcode,dname,param,dist,cdffunc,invcdffunc)
%CREATEPROBPLOT Create an empty probability plot of a particular type

% Create a set of axes if none supplied
if isempty(hAxes)
   hAxes = cla('reset');
end

% Store information about the reference distribution
setappdata(hAxes,'ReferenceDistribution',dcode);
setappdata(hAxes,'CdfFunction',cdffunc);
setappdata(hAxes,'InverseCdfFunction',invcdffunc);
setappdata(hAxes,'DistributionParameters',param);
setappdata(hAxes,'LogScale',dist.uselogpp);
setappdata(hAxes,'DistSpec',dist);

% Add labels and a title
set(get(hAxes,'XLabel'),'String','Data');
set(get(hAxes,'YLabel'),'String','Probability');
if isempty(param)
    paramtext = '';
else
    fmt = repmat('%g,',1,length(param));
    fmt(end) = [];
    paramtext = sprintf(['(' fmt ')'],param{:});
end
set(get(hAxes,'Title'),'String',...
                     sprintf('Probability plot for %s%s distribution',...
                             dname,paramtext));

% Set X axis to log scale if this distribution uses that scale
if dist.uselogpp
   set(hAxes,'XScale','log');
end

% ------------------------------------
function hdata = adddatapoints(hAxes,x,ppos,originds)
%ADDDATAPOINTS Add points representing data to a probability plot
%   x is already sorted

% Get information about the reference distribution
invcdffunc = getappdata(hAxes,'InverseCdfFunction');
param = getappdata(hAxes,'DistributionParameters');

% Compute y values for this distribution
q = feval(invcdffunc,ppos,param{:});

% Add to plot
hdata = line(x,q,'Parent',hAxes);

% Attach custom data cursor
for i=1:length(hdata)
    hB = hggetbehavior(hdata(i),'datacursor');
    set(hB,'UpdateFcn',{@probplotDatatipCallback,hAxes});
    if ~isempty(originds)
        setappdata(hdata(i),'originds',originds(:,i));
    end
    if numel(hdata)>1
        setappdata(hdata(i),'group',i);
    end
end

% Use log X scale if distribution requires it
xmin = min(x(1,:));
xmax = max(x(end,:));
if isequal(get(hAxes,'XScale'),'log')
    xmin = log(xmin);
    xmax = log(xmax);
    dx = 0.02 * (xmax - xmin);
    if (dx==0)
       dx = 1;
    end
    xmin = exp(xmin - dx);
    xmax = exp(xmax + dx);
    newxlim = [xmin xmax];
else
    dx = 0.02 * (xmax - xmin);
    if (dx==0)
       dx = 1;
    end
    newxlim = [xmin-dx, xmax+dx];
end
oldxlim = get(hAxes,'XLim');
set(hAxes,'XLim',[min(newxlim(1),oldxlim(1)), max(newxlim(2),oldxlim(2))]);

% Make sure they have different markers and no connecting line
markerlist = {'x','o','+','*','s','d','v','^','<','>','p','h'}';
set(hdata,'LineStyle','none','Tag','data',...
          {'Marker'},markerlist(1+mod((1:length(hdata))-1,length(markerlist))));

% -------------------------------------------
function setprobticks(hAxes)
%SETPROBTICKS Set the y axis tick marks to use a probability scale

invcdffunc = getappdata(hAxes,'InverseCdfFunction');
param = getappdata(hAxes,'DistributionParameters');

% Define tick locations
ticklevels = [.0001 .0005 .001 .005 .01 .05 .1 .25 .5 ...
              .75 .9 .95 .99 .995 .999 .9995 .9999];
tickloc = feval(invcdffunc,ticklevels,param{:});

% Remove ticks outside axes range
set(hAxes,'YLimMode','auto');
ylim = get(hAxes,'YLim');
t = tickloc>=ylim(1) | tickloc<=ylim(2);
tickloc = tickloc(t);
ticklevels = ticklevels(t);

% Remove ticks that are too close together
j0 = ceil(length(tickloc)/2);
delta = .025*diff(ylim);
j = j0-1;
keep = true(size(tickloc));
while(j>0)
   if tickloc(j) > tickloc(j0)-delta
      keep(j) = false;
   else
      j0 = j;
   end
   j = j-1;
end
j = j0+1;
while(j<length(tickloc))
   if tickloc(j) < tickloc(j0)+delta
      keep(j) = false;
   else
      j0 = j;
   end
   j = j+1;
end

if ~all(keep)
   tickloc = tickloc(keep);
   ticklevels = ticklevels(keep);
end
set(hAxes,'YTick',tickloc,'YTickLabel',ticklevels);

% -------------------------------------------
function [x,ppos] = getppos(x,cens,freq)
%GETPPOS Get plotting positions for probability plot

if isempty(cens) && isempty(freq)
   % Use a simple definition compatible with the censored calculation.
   % Plot sorted x(i) against (i-1/2)/n.
   % This code supports X as a matrix or a vector.
   if ~any(isnan(x(:)))
       n = size(x,1);
       ppos = ((1:n)' - 0.5) / n;
   else
       % Any NaNs in X were sorted to the bottom, so we will fill in
       % ppos values starting at the top
       ppos = nan(size(x));
       for j=1:size(x,2)
           n = sum(~isnan(x(:,j)));
           ppos(1:n,j) = ((1:n)' - 0.5) / n;
       end
   end
else
   % Compute the empirical cdf
   [fecdf,xecdf,temp1,temp2,D] = ecdf(x,'cens',cens,'freq',freq); %#ok<ASGLU>
   
   % Create outputs with one row for each observed failure
   N = sum(min(100,D));
   xout = zeros(N,1);
   ppos = zeros(N,1);
   
   % Fill in with points equally spaced at each jump of the cdf
   % If there are M failures at x(i), plot x(i) against the M values
   % equally spaced between F(x(i)-) and F(x(i)+)
   xbase = 0;
   for j=1:length(xecdf)-1;
      Dj = D(j);
      Npts = min(100,Dj);
      rownums = xbase+(1:Npts);
      xout(rownums) = xecdf(j+1);
      ppos(rownums) = fecdf(j) + ((1:Npts)-0.5) * (fecdf(j+1)-fecdf(j)) / Npts;
      xbase = xbase + Npts;
   end
   
   % Replace old data with the new version
   x = xout;
end

% -------------------------------------------
function refxy = getrefxy(x,probpoints,invcdffunc,param,uselogpp)
%GETREFXY Get two points on a reference line

if isempty(probpoints)
   % If there is no censoring, we get the first and third quartiles
   P1 = .25;
   P3 = .75;
   DataQ = prctile(x,100*[P1; P3]);
   DataQ1 = DataQ(1);
   DataQ3 = DataQ(2);
else
   % Get upper quartile, or as high up as we can go
   P3 = min(.75,probpoints(end));
   DataQ3 = interp1(probpoints,x,P3);
   
   % Get lower quartile or a substitute for it
   P1 = max(P3/3,probpoints(1));
   DataQ1 = interp1(probpoints,x,P1);
end

% Use log scale if necessary
if uselogpp
   DataQ1 = log(DataQ1);
   DataQ3 = log(DataQ3);
end

% Get the y values for these x values
DistrQ = feval(invcdffunc, [P1 P3], param{:});

% Package up the points and return them
if DataQ3 > DataQ1 % make sure we have distinct points
   refxy = [DataQ1 DistrQ(1)
            DataQ3 DistrQ(2)];
else
   refxy = [];
end

% ------------------------------------------
function hfit = ppaddfit(hAxes,cdffunc,params)
%PPADDFIT Add fit to probability plot

if nargin<3 || isempty(params)
   params = {};
elseif isnumeric(params)
   params = num2cell(params);
end

% Define function using local function handle
if feature('HGUsingMATLABClasses')    
    hfit = specgraphhelper('createFunctionLineUsingMATLABClasses',...
                 'Function',@calcfit,'UserArgs',{hAxes,cdffunc,params},...
                 'Parent',hAxes);
else                 
    hfit = graph2d.functionline(@calcfit,'-userargs',{hAxes,cdffunc,params},...
                            'Parent',hAxes);
end
                        
% Add custom data cursor
hB = hggetbehavior(hfit,'datacursor');
set(hB,'UpdateFcn',{@probplotDatatipCallback,hAxes});

% Start off with reasonable default properties
set(hfit,'XLimInclude','off','YLimInclude','off',...
         'Color','k','LineStyle','--','Tag','fit');

% ------------------------------------------
function fx = calcfit(x,hAxes,cdffunc,fitparams)
%CALCFIT Calculated values of function for plot

% Get y values in units of the tick mark labels
p = feval(cdffunc,x,fitparams{:});

% Get y values in units of the real y axis
invcdffunc = getappdata(hAxes,'InverseCdfFunction');
plotparams = getappdata(hAxes,'DistributionParameters');
fx = feval(invcdffunc,p,plotparams{:});

% ------------------------------------------
function [hAxes,newdist,dist,param,vin] = getdistname(vin)
%GETDISTNAME Get probability distribution info from user input

% Check for probability plot axes handle as a first argument
if numel(vin{1})==1 && ishghandle(vin{1})
   hAxes = vin{1};
   if ~isequal(get(hAxes,'Type'),'axes')
      error('stats:probplot:BadHandle','Invalid axes handle.');
   end
   vin(1) = [];
else
   hAxes = [];
end

% Now get the distribution name and parameters for it
if ~isempty(vin) && isa(vin{1},'ProbDist') && isempty(hAxes)
   % ProbDist object followed by data
   pd = vin{1};
   dist = dfgetdistributions(pd.DistName);
   newdist = true;
   vin(1) = [];
   param = num2cell(pd.Params);
elseif ~isempty(vin) && (ischar(vin{1}) || iscell(vin{1}))
   % Preference is to use passed-in name, if any
   dname = vin{1};
   vin(1) = [];
   newdist = true;
   
   % May be passed in as a name or a {dist,param} array
   if iscell(dname)
      dist = dname{1};
      param = num2cell(dname{2});
   elseif ischar(dname)
      if strncmpi(dname,'ev',length(dname))
          dname = 'extreme value';
      elseif strncmpi(dname,'wbl',length(dname))
          dname = 'weibull';
      end
      dist = dfgetdistributions(dname);
      if ~isscalar(dist)
         error('stats:probplot:BadDistribution',...
               'Unknown distribution name "%s".', dname);
      elseif ~dist.islocscale
         error('stats:probplot:InappropriateDistribution',...
               ['The %s distribution requires estimated parameters,\n' ...
                'so it cannot be used to create a probability plot.'], ...
               dname);
      end
      param = {};
   else
      error('stats:probplot:BadDistribution','Bad distribution name.');
   end   
elseif isempty(hAxes)
   % Use default if no axes passed in
   dname = 'normal';
   param = {};
   newdist = true;
   dist = dfgetdistributions(dname);
else
   % Otherwise use current distribution
   dname = getappdata(hAxes,'ReferenceDistribution');
   param = getappdata(hAxes,'DistributionParameters');
   if isempty(getappdata(hAxes,'InverseCdfFunction')) || ~iscell(param)
      error('stats:probplot:BadHandle','Not a probability plot.')
   end
   newdist = false;
   dist = dfgetdistributions(dname);
end

% ------------------------------------------
function [x,cens,freq,originds] = checkdata(dist,varargin)
%CHECKDATA Get data and check that it works with this distribution

x = varargin{1};
if length(varargin)<2
   cens = [];
else
   cens = varargin{2};
end
if length(varargin)<3
   freq = [];
else
   freq = varargin{3};
end

if ~isempty(cens) || ~isempty(freq)
    % Remove NaNs now if we have to maintain x, cens, and freq in parallel.
    % Otherwise if we don't have cens and freq, we'll deal with NaNs in x
    % as required.  X must be a vector in this case.
    [ignore1,ignore2,x,cens,freq] = statremovenan(x,cens,freq); %#ok<ASGLU>
end

% Follow the usual convention by treating a row vector as a column
if ndims(x)>2
   error('stats:probplot:InvalidData','Y must be a vector or matrix.')
end
if size(x,1)==1
   x = x';
end
[x,sortidx] = sort(x);

[nobs,nsamples] = size(x);
if ~isempty(cens)
   if length(cens)~=nobs || ~(isnumeric(cens) || islogical(cens))
      error('stats:probplot:InputSizeMismatch',...
            'Y and CENS must have the same number of observations.')
   end
   cens = cens(sortidx);
end
if ~isempty(freq)
   if length(freq)~=nobs || ~(isnumeric(freq) || islogical(freq))
      error('stats:probplot:InputSizeMismatch',...
            'Y and FREQ must have the same number of observations.')
   end
   freq = freq(sortidx);
end
if isempty(freq) && isempty(cens)
    originds = sortidx;
else
    originds = [];
end

% Check match between data and distribution.
xmin = min(x(1,:));
xmax = max(x(end,:));
if xmin==dist.support(1) && ~dist.closedbound(1)
    error('stats:probplot:InappropriateDistribution',...
          'The %s distribution requires data greater than %g.',...
          dist.name,dist.support(1));
elseif xmin<dist.support(1)
    error('stats:probplot:InappropriateDistribution',...
          'The %s distribution requires data no less than %g.',...
          dist.name,dist.support(1));
elseif xmax==dist.support(2) && ~dist.closedbound(2)
    error('stats:probplot:InappropriateDistribution',...
          'The %s distribution requires data less than %g.',...
          dist.name,dist.support(2));
elseif xmax>dist.support(2)
    error('stats:probplot:InappropriateDistribution',...
          'The %s distribution requires data no greater than %g.',...
          dist.name,dist.support(2));
elseif (nsamples>1) && ~dist.islocscale
    error('stats:probplot:InappropriateDistribution',...
          'Only a single sample is allowed with the %s distribution',...
          dist.name);
elseif (~isempty(cens) || ~isempty(freq)) && (nsamples>1)
    error('stats:probplot:InvalidData',...
          'Only a single sample is allowed with censoring or frequencies.');
end


% ------------------------------------------
function datatipTxt = probplotDatatipCallback(obj,evt,hAxes)

target = get(evt,'Target');
ind = get(evt,'DataIndex');
pos = get(evt,'Position');

x = pos(1);
y = pos(2);

cdffunc = getappdata(hAxes,'CdfFunction');
param = getappdata(hAxes,'DistributionParameters');

% Compute position to display.
yper = cdffunc(y,param{:});

% Get the original row number of the selected point, which is set if 
% freq and cens are left unspecified. Also empty for reference lines.
originds = getappdata(target,'originds');

% Get the group number, which is set on points and reference lines 
% if more than one series.
group = getappdata(target,'group');

% Generate text to display.
datatipTxt = {
    ['Data: ',num2str(x)],...
    ['Probability: ',num2str(yper)],...
    };
if ~isempty(originds) || ~isempty(group)
    datatipTxt{end+1} = '';
end
if ~isempty(originds)
    origind = originds(ind);
    datatipTxt{end+1} = ['Observation: ',num2str(origind)];
end
if ~isempty(group)
    datatipTxt{end+1} = ['Group: ',num2str(group)];
end

