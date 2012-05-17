function hFit = dfaddsmoothfit(hFit, fitname, kernelname, widthradio, widthtext, dsname, fitframe, supportradio, supporttext, exclname, fittingPanel)
%DFADDSMOOTHFIT Add smooth fit in dfittool

%   $Revision: 1.1.8.3 $  $Date: 2010/05/10 17:59:39 $
%   Copyright 2003-2007 The MathWorks, Inc.

isgood = true;

if isempty(hFit)
    newfit = true;
    % Create the fit
    hFit = stats.dffit(fitname, fitframe);
else
    newfit = false;
end

listeners = hFit.listeners;
set(listeners, 'Enabled', 'off');

if supportradio == 2
   support = supporttext;
   try
      L = str2double(support(1));
      U = str2double(support(2));
   catch
      L = NaN;
      U = NaN;
   end
   if isnan(L) || isnan(U) || L>U
      emsg = 'Invalid values for specified domain bounds.';
      fittingPanel.setResults(emsg);
      hFit.resultstext = emsg;
      errordlg(emsg,'Domain Invalid');
      if ~isempty(hFit)
         isgood = false;
      end
   end
   support = [L U];
elseif supportradio == 1
   support = 'positive';
   L = 0;
   U = Inf;
else  %unbounded
   support = 'unbounded';
   L = -Inf;
   U = Inf;
end

% Get data set to fit
ds=find(getdsdb,'name',dsname);

if widthradio == 0
    width = [];
else
    width = str2num(widthtext);
end

% Get the range over which to show the fit
dffig = dfgetset('dffig');
ax = findall(dffig,'Type','axes','Tag','main');
xlim = get(ax,'XLim');

% Make sure the data are within range
hExcl = dfgetexclusionrule(exclname);
[ydata, cens, freq] = getincludeddata(ds,hExcl);

if isempty(ydata)
   emsg = 'No data remaining after exclusion rule applied.';
   fittingPanel.setResults(emsg);
   hFit.resultstext = emsg;
   isgood = false;
end

if isgood && ((min(ydata)<=L) || (max(ydata)>=U))
   emsg = 'Data out of range of specified domain bounds.';
   fittingPanel.setResults(emsg);
   hFit.resultstext = emsg;
   errordlg(emsg,'Domain Invalid');
   isgood = false;
end

if ~newfit && ~(hFit.isgood == isgood)
	sendIsGoodChangeNotification = true;
else
	sendIsGoodChangeNotification = false;
end

try
   censargs = {'cens' cens 'freq' freq};
   kernelargs = {'kernel' kernelname 'support' support 'width' width};
   pd = fitdist(ydata,'kernel', censargs{:}, kernelargs{:});
    
   % Update its properties
   hFit.dshandle = ds;
   hFit.dataset=dsname;
   hFit.bandwidth = width;
   hFit.bandwidthtext = widthtext;
   hFit.bandwidthradio = widthradio;
   hFit.kernel = kernelname;
   hFit.xlim = xlim;
   hFit.fittype = 'smooth';
   hFit.support = support;
   hFit.supportlower = supporttext{1};
   hFit.supportupper = supporttext{2};
   hFit.supportradio = supportradio;
   hFit.exclusionrule = hExcl;
   hFit.exclusionrulename = exclname;
   hFit.isgood = isgood;
   hFit.enablebounds = 0;
   hFit.probdist = pd;
   hFit.version = 2;  % version 2 contains probdist object
   setftype(hFit,dfgetset('ftype'));
   success = true;
catch
   success = false;
end

if success
   if newfit
      % Add to fit array
      hFit.plot = 1;
      connect(hFit,getfitdb,'up');
   end

   if sendIsGoodChangeNotification
		com.mathworks.toolbox.stats.FitsManager.getFitsManager.fitIsGoodChanged(java(hFit), isgood);
   end
   
   if ~newfit
      com.mathworks.toolbox.stats.FitsManager.getFitsManager.fitChanged(...
        java(hFit),fitname,fitname);
   end
end
   
if hFit.plot
	% Update plotted curve
	updateplot(hFit);

	% Update plot limits
	dfswitchyard('dfupdatexlim');
	dfswitchyard('dfupdateylim');
end

if isgood
   % Show results, must be done after bandwidth is filled in during plotting
   resultsText = getresults(hFit);
   hFit.resultstext = resultsText;
   fittingPanel.setResults(resultsText);
end

dfgetset('dirty',true);   % session has changed since last saved

set(listeners, 'Enabled', 'on');
