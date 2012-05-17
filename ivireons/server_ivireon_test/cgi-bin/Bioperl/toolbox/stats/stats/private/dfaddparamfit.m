function hFit = dfaddparamfit(hFit, fitname, distname, dsname, fitframe, exclname, useestimated, fixedvals, fittingPanel)
%DFADDPARAMFIT Add parametric fit in dfittool

%   $Revision: 1.1.8.3 $  $Date: 2010/05/10 17:59:38 $
%   Copyright 2003-2008 The MathWorks, Inc.

badfit = false;    % badfit=true means fit failed or not attempted
if isempty(hFit)
    newfit = true;
    hFit = stats.dffit(fitname, fitframe);
else
    newfit = false;
end
listeners = hFit.listeners;
set(listeners, 'Enabled', 'off');

% Get data set to fit
ds=find(getdsdb,'name',dsname);
hFit.distname = distname;
hFit.dataset  = dsname;
hFit.fittype = 'param'; 
hFit.dshandle = ds;

% Store some GUI values in fit
hFit.pfixedtext = fixedvals;
hFit.pestimated = useestimated;

% Extract data from this data set
hExcl = dfgetexclusionrule(exclname);
[x, cens, freq] = getincludeddata(ds,hExcl);

% Get information about the requested distribution
emsg = '';
wmsg = '';
dist = dfgetdistributions(distname);
if length(dist)~=1 || isempty(x)
   if length(dist)~=1
      emsg = 'Bad distribution name.';
   else
      emsg = 'No data remaining after exclusion rule applied.';
   end
   badfit = true;
end
if length(dist)==1
   hFit.enablebounds = dist.hasconfbounds;
end

% Perform the fit
lastwarn('');
ws = warning('off');
if badfit
   p = [];
   pd = [];
else
   try
      nparams = length(dist.pnames);
      censargs = {'cens' cens 'freq' freq};
   
      fixedparams = cell(1,2*sum(~useestimated));
      if any(~useestimated)
         k = 1;
         for j=1:nparams
            if ~useestimated(j)
               txt = deblank(fixedvals{j});
               if isempty(txt)
                  error('stats:dfaddparamfit:BadParam',...
                        'Invalid value for parameter %s', dist.pnames{j});
               end
               num = str2double(txt);
               if ~isfinite(num)
                  error('stats:dfaddparamfit:BadParam',...
                        'Invalid value for parameter %s', dist.pnames{j});
               end
               fixedparams{k} = dist.pnames{j};
               fixedparams{k+1} = num;
               k = k+2;
            end
         end
      end
   
      % Do the fit
      pd = fitdist(x,dist, censargs{:}, fixedparams{:});
      p = pd.Params;
   catch ME
      p = [];
      pd = [];
      emsg = ME.message;
      badfit = true;
   end
end
warning(ws);

if ~badfit
   if ~isempty(lastwarn)
      wmsg = sprintf('Warning:  %s',lastwarn);
   else
      wmsg = '';
   end
   newmsg = '';
   if any(~isfinite(p))
      newmsg = 'Fit produced infinite parameter estimates.';
   elseif numel(p)~=numel(dist.pnames) || ~isnumeric(p)
      newmsg = 'Fit function returned bad parameter values';
   end
   if ~isempty(newmsg)
      badfit = true;
      emsg = combinemsg(emsg,newmsg);
   end
end

% Get the range over which to show the fit
dffig = dfgetset('dffig');
ax = findall(dffig,'Type','axes','Tag','main');
xlim = get(ax,'XLim');

% Create a fit object using the information we calculated
if badfit
   resultsText = emsg;
else
   try
      hFit = storefitresults(hFit, dist, pd, xlim, hExcl, exclname);
      resultsText = getresults(hFit);
   catch ME
      resultsText = ME.message;
      badfit = true;
   end
end

resultsText = combinemsg(wmsg,resultsText);

% Show results
hFit.resultstext = resultsText;
javaMethodEDT('setResults', fittingPanel, resultsText);

if ~isempty(hFit)
   if ~newfit && ~(hFit.isgood == ~badfit)
   		com.mathworks.toolbox.stats.FitsManager.getFitsManager.fitIsGoodChanged(java(hFit), ~badfit);
   end
   hFit.isgood = ~badfit;
   if newfit
	  hFit.plot = 1;
      % Add to fit array
      connect(hFit,getfitdb,'up');
   end
end

if hFit.plot
   % Determine if bounds can be shown
   if ~dist.hasconfbounds
      hFit.showbounds = false;
   end
   
   % Update plotted curve
   updateplot(hFit);

   % Update plot limits
   dfswitchyard('dfupdatexlim');
   dfswitchyard('dfupdateylim');
end

set(listeners, 'Enabled', 'on');

if ~newfit
   com.mathworks.toolbox.stats.FitsManager.getFitsManager.fitChanged(...
       java(hFit),fitname,fitname);
end

dfgetset('dirty',true);   % session has changed since last save

% Display a more prominent warning outside the results text
if ~badfit && ~isempty(wmsg)
   warndlg(wmsg,'Distribution Fitting Warning','modal');
end

% ----------------------------------------------
function hFit = storefitresults(hFit, dist, pd, xlim, hExcl, exclname)

if isempty(pd)
    p = [];
    pcov = [];
    nlogl = NaN;
else
    p = pd.Params;
    pcov = pd.ParamCov;
    nlogl = pd.NLogL;
    if isnan(nlogl)
        nlogl = NaN; % explicitly assign to insure no imaginary part
    end
end

% Update its properties
hFit.distspec = dist;
hFit.params   = p;
hFit.pcov     = pcov;
hFit.pfixed   = false(size(p));
hFit.loglik = -nlogl;
hFit.support = dist.support;
hFit.exclusionrule = hExcl;
hFit.exclusionrulename = exclname;
hFit.probdist = pd;
hFit.version = 2;  % version 2 contains probdist object

hFit.xlim = xlim;
setftype(hFit,dfgetset('ftype'));


% -----------------------------------
function msg = combinemsg(msg,newmsg)
%COMBINEMSG Combine multiple messages into a single message
if isempty(msg)
   msg = newmsg;
elseif ~isempty(newmsg)
   msg = sprintf('%s\n\n%s',msg,newmsg);
end
