function dffig2m(dffig,outfilename)
%DFFIG2M Turn figure into generated code that can produce the figure

%   $Revision: 1.1.8.3 $  $Date: 2010/05/10 17:59:41 $
%   Copyright 2003-2010 The MathWorks, Inc.

dsdb = getdsdb;
fitdb = getfitdb;
if isempty(down(dsdb)) && isempty(down(fitdb))
   emsg = 'Cannot generate code when no datasets or fits exist.';
   errordlg(emsg,'Error Generating Code','modal');
   return
end

if nargin<1
   dffig = dfgetset('dffig'); 
end

if nargin<2
   % Get file name to use, remember the directory name
   olddir = dfgetset('dirname');
   filespec = [olddir '*.m'];
   [outfilename,pn] = uiputfile(filespec,'Save generated code to file');
   if isequal(outfilename,0) || isequal(pn,0)
      return
   end
   if ~ismember('.',outfilename)
      outfilename = [outfilename '.m'];
   end
   dfgetset('dirname',pn);
   outfilename = sprintf('%s%s',pn,outfilename);
end

% Get file name with .m suffix, and get corresponding function name
if length(outfilename)<2 || ~isequal(outfilename(end-1:end),'.m')
   outfilename = sprintf('%s.m',outfilename);
end
fcnname = outfilename(1:end-2);
k = find(fcnname(1:end-1)=='\',1,'last');
if ~isempty(k)
   fcnname = fcnname(k+1:end);
end
k = find(fcnname(1:end-1)=='/',1,'last');
if ~isempty(k)
   fcnname = fcnname(k+1:end);
end
   

% Set up some variables for later
allprop = {'Color' 'Marker' 'LineStyle' 'LineWidth' 'MarkerSize'};
ftype = dfgetset('ftype');
alpha = 1 - dfgetset('conflev');
showlegend = isequal(dfgetset('showlegend'),'on');
axold = get(dffig,'CurrentAxes');
leginfo = {};
if showlegend
   legh = legend(axold);
   leginfo = dfgetlegendinfo(legh);
   legloc = get(legh,'Location');
   if isequal(legloc,'none')
      oldu = get(legh,'units');
      legpos = get(legh,'position');
      legpos = hgconvertunits(dffig,legpos,oldu,'normalized',dffig);
      legloc = legpos(1:2);
   end
end

% Create arrays to receive code text
blkc = cell(0,1);    % block of comment lines
blks = cell(0,1);    % block of setup lines
blkd = cell(0,1);    % block of data-related lines
blkf = cell(0,1);    % block of fit-related lines
blke = cell(0,1);    % block of lines at end

% Write introduction to dataset section, including figure
% preparation code
blks{end+1} = '% Set up figure to receive datasets and fits';
blks{end+1} = 'f_ = clf;';
blks{end+1} = 'figure(f_);';
fpos = dfgetfigurepos(dffig,'pixels');
blks{end+1} = sprintf('set(f_,''Units'',''Pixels'',''Position'',[%g %g %g %g]);',fpos);
if showlegend
   blks{end+1} = 'legh_ = []; legt_ = {};   % handles and text for legend';
end

% Process each dataset
exprlist = {};    % names and expressions of the data, censoring, frequency
arglist = {};     % variable names to use for each expression
ds = down(dsdb);
numds = 0;
ndsplotted = 0;
while(~isempty(ds))
   numds = numds + 1;
   [blkc,blkd,exprlist,arglist,showbounds,onplot] = ...
                 writedset(blkc,blkd,ds,exprlist,arglist,allprop,alpha);

   if onplot && showlegend
      blkd{end+1} = 'legh_(end+1) = h_;';
      blkd{end+1} = sprintf('legt_{end+1} = ''%s'';',quotedtext(ds.name));
      if showbounds
         blkd{end+1} = 'legh_(end+1) = hb_;';
         blkd{end+1} = sprintf('legt_{end+1} = ''%g%% confidence bounds'';',...
                               100*(1-alpha));
      end
   end
   if onplot
       ndsplotted = ndsplotted + 1;
   end
   ds = right(ds);
end

% Force all inputs to be column vectors
blkc{end+1} = ' ';
blkc{end+1} = '% Force all inputs to be column vectors';
for j=1:length(arglist)
   blkc{end+1} = sprintf('%s = %s(:);',arglist{j},arglist{j});
end

% Set up for plotting fits
anycontinuous = false;
anydiscrete = false;
ft = down(fitdb);
while(~isempty(ft))
   if ft.iscontinuous
      anycontinuous = true;
   else
      anydiscrete = true;
   end
   ft = right(ft);
end

% Create a suitable X vector, may depend on whether it's discrete
if ~isequal(ftype,'pdf') || ~anydiscrete
   blkf{end+1} = sprintf('x_ = linspace(xlim_(1),xlim_(2),100);');
elseif ~anycontinuous
   blkf{end+1} = 'incr_ = max(1,floor((xlim_(2)-xlim_(1))/100));';
   blkf{end+1} = 'x_ = floor(xlim_(1)):incr_:ceil(xlim_(2));';
else
   blkf{end+1} = sprintf('xc_ = linspace(xlim_(1),xlim_(2),100);');
   blkf{end+1} = 'incr_ = max(1,floor((xlim_(2)-xlim_(1))/100));';
   blkf{end+1} = 'xd_ = floor(xlim_(1)):incr_:ceil(xlim_(2));';
end

% Process each fit
numfit = 0;
ft = down(fitdb);
anySmoothFits = false;
while(~isempty(ft))
   numfit = numfit+1;
   fitname = ft.name;

   % Create code to re-create this fit
   blkf{end+1} = sprintf('\n%% --- Create fit "%s"',fitname);

   % Call subfunction to generate code for each type
   if isequal(getfittype(ft),'param')
      [blkf,showbounds,onplot] = writepfit(blkf,ft,alpha,allprop,...
                                    anycontinuous,anydiscrete,exprlist,arglist);
   else
      anySmoothFits = true;
      [blkf,onplot] = writenpfit(blkf,ft,alpha,allprop,...
                                 anycontinuous,anydiscrete,exprlist,arglist);
      showbounds = false;
   end

   % Add legend if requested
   if onplot && showlegend
      blkf{end+1} = 'legh_(end+1) = h_;';
      blkf{end+1} = sprintf('legt_{end+1} = ''%s'';',quotedtext(ft.name));
      if showbounds
         blkf{end+1} = 'legh_(end+1) = hb_;';
         blkf{end+1} = sprintf('legt_{end+1} = ''%g%% confidence bounds'';',...
                               100*(1-alpha));
      end
   end
   ft = right(ft);
end

% In setup section, create empty axes and set some properties
if ~isequal(ftype,'probplot')
   blks{end+1} = 'ax_ = newplot;';
else
   dtype = dfgetset('dtype');
   if ischar(dtype)
      blks{end+1} = sprintf('probplot(''%s'');', dtype);
   else
      blks{end+1} = sprintf(...
          'dist_ = dfswitchyard(''dfgetdistributions'',''%s'');',...
          dtype.distspec.code);
      blks{end+1} = sprintf('probplot({dist_,%s});',...
                            cell2text(num2cell(dtype.params)));
   end
   blks{end+1} = 'ax_ = gca;';
   blks{end+1} = 'title(ax_,'''');';
end

blks{end+1} = 'set(ax_,''Box'',''on'');';
if isequal(dfgetset('showgrid'),'on')
   blks{end+1} = 'grid(ax_,''on'');';
end
blks{end+1} = 'hold on;';

% At end of data set section, set x axis limits
if ndsplotted>0
    % This is the typical case where we plot the data and evaluate the fit
    % over the plotted range
    blkd{end+1} = 'xlim_ = get(ax_,''XLim'');';
else
    % In this unusual case we have to select a range for the fit
    blkd{end+1} = sprintf('\n%% Get data limits to determine plotting range');
    ds = down(dsdb);
    yname = expression2name(ds.yname,exprlist,arglist);
    blkd{end+1} = sprintf('xlim_ = [min(%s), max(%s)];',yname,yname);
    while(true)
        ds = right(ds);
        if isempty(ds)
            break
        end
        yname = expression2name(ds.yname,exprlist,arglist);
        blkd{end+1} = sprintf('xlim_(1) = min(xlim_(1), min(%s));',yname);
        blkd{end+1} = sprintf('xlim_(2) = max(xlim_(2), max(%s));',yname);
    end
end

blkd{end+1} = sprintf('\n%% Nudge axis limits beyond data limits');
blkd{end+1} = 'if all(isfinite(xlim_))';
if isequal(get(axold,'XScale'),'log')
   blkd{end+1} = '   xlim_ = exp(log(xlim_) + [-1 1] * 0.01 * diff(log(xlim_)));';
else
   blkd{end+1} = '   xlim_ = xlim_ + [-1 1] * 0.01 * diff(xlim_);';
end
blkd{end+1} = '   set(ax_,''XLim'',xlim_)';
blkd{end+1} = 'end';

% Finish up
blke{end+1} = 'hold off;';
if showlegend
   blke{end+1} = sprintf('leginfo_ = %s; % properties of legend', ...
                         cell2text(leginfo,true));

   if isnumeric(legloc)
      blke{end+1} = 'h_ = legend(ax_,legh_,legt_,leginfo_{:}); % create and reposition legend';
      blke{end+1} = 'set(h_,''Units'',''normalized'');';
      blke{end+1} = 't_ = get(h_,''Position'');';
      blke{end+1} = sprintf('t_(1:2) = [%g,%g];',legloc);
      blke{end+1} = 'set(h_,''Interpreter'',''none'',''Position'',t_);';
   else
      blke{end+1} = 'h_ = legend(ax_,legh_,legt_,leginfo_{:});  % create legend';
      blke{end+1} = 'set(h_,''Interpreter'',''none'');';
   end
end

% Write code into file
if isempty(arglist)
   argtext = '';
else
   argtext = sprintf('%s,',arglist{:});
   argtext = sprintf('(%s)',argtext(1:end-1));
end
[fid,msg] = fopen(outfilename,'w');
if fid==-1
   emsg = sprintf('Error trying to write to %s:\n%s',outfilename,msg);
   errordlg(emsg,'Error Saving M File','modal');
   return
end
fprintf(fid,'function %s%s\n',fcnname,argtext);
fprintf(fid,'%%%s    Create plot of datasets and fits\n',upper(fcnname));
fprintf(fid,'%%   %s%s\n',upper(fcnname),upper(argtext));
fprintf(fid,'%%   Creates a plot, similar to the plot in the main distribution fitting\n');
fprintf(fid,'%%   window, using the data that you provide as input.  You can\n');
fprintf(fid,'%%   apply this function to the same data you used with dfittool\n');
fprintf(fid,'%%   or with different data.  You may want to edit the function to\n');
fprintf(fid,'%%   customize the code and this help message.\n');
fprintf(fid,'%%\n');
fprintf(fid,'%%   Number of datasets:  %d\n',numds);
fprintf(fid,'%%   Number of fits:  %d\n',numfit);
fprintf(fid,'\n');
fprintf(fid,'%% This function was automatically generated on %s\n',...
            datestr(now));
for j=1:length(blkc)
   fprintf(fid,'%s\n',xlate(blkc{j}));
end
fprintf(fid,'\n');
for j=1:length(blks)
   fprintf(fid,'%s\n',xlate(blks{j}));
end
fprintf(fid,'\n');
for j=1:length(blkd)
   fprintf(fid,'%s\n',xlate(blkd{j}));
end
fprintf(fid,'\n');
for j=1:length(blkf)
   fprintf(fid,'%s\n',xlate(blkf{j}));
end
fprintf(fid,'\n');
for j=1:length(blke)
   fprintf(fid,'%s\n',xlate(blke{j}));
end

% Create sub function to be used to support a functionline fit on a probability plot
if anySmoothFits && isequal(ftype,'probplot')
   fprintf(fid,'\n\n%% -----------------------------------------------\n');
   fprintf(fid,'function f=cdfnp(x,y,cens,freq,support,kernel,width)\n');
   fprintf(fid,'%%CDFNP Compute cdf for non-parametric fit, used in probability plot\n\n');
   fprintf(fid,'f = ksdensity(y,x,''cens'',cens,''weight'',freq,''function'',''cdf'',...\n');
   fprintf(fid,'                  ''support'',support,''kernel'',kernel,''width'',width);\n');
end

fclose(fid);

% ------------------- double up quotes in text string
function a = quotedtext(b)
if ischar(b)
   a = strrep(b,'''','''''');
else
   a = sprintf('%.13g',b);
end

% ------------------- create text to re-create cell or numeric array
function a = cell2text(b,preservecell)

% This is not a completely general-purpose routine, but it handles the sort
% of cell arrays used here.  A cell array containing a matrix, for
% instance, would not work
if ~iscell(b)
   if ischar(b)
      a = sprintf('''%s''',quotedtext(b));
   elseif length(b)==1
      a = sprintf('%.13g',b);
   else
      numtext = num2str(b,'%.13g ');
      if size(numtext,1)>1
         numtext = [numtext repmat(';',size(numtext,1),1)]';
         numtext = numtext(:)';
         numtext = numtext(1:end-1);
      end
      a = sprintf('[%s]',numtext);
   end
   return
end

if ~isempty(b)
   bj = b{1};
   if ischar(bj)
      a = sprintf('''%s''',quotedtext(bj));
   else
      a = sprintf(' %.13g',bj);
   end
   for j=2:length(b)
      bj = b{j};
      if ischar(bj)
         a = sprintf('%s, ''%s''',a,quotedtext(bj));
      elseif isscalar(bj)
         a = sprintf('%s, %.13g',a,bj);
      else
         a = sprintf('%s, [%s]',a,sprintf(' %.13g',bj));
      end
   end
else
   a = '';
end
if nargin<2 || ~preservecell
    a = sprintf('[%s]',a);
else
    a = sprintf('{%s}',a);
end


% ----------------- add censoring and frequency args to code block
function blk = addcensfreq(blk,censname,freqname)

if ~isempty(censname) && ~isequal(censname,'[]')
   blk{end+1} = sprintf('               ,''cens'',%s...',censname);
end
if ~isempty(freqname) && ~isequal(freqname,'[]')
   blk{end+1} = sprintf('               ,''freq'',%s...',freqname);
end


% ---------------- write code for parametric fit
function [blkf,showbounds,onplot] = ...
    writepfit(blkf,ft,alpha,allprop,anycontinuous,anydiscrete,exprlist,arglist)

ds = ft.ds;
yname = expression2name(ds.yname,exprlist,arglist);
dist = ft.distspec;
ftype = ft.ftype;
onplot = true;

blkf{end+1} = sprintf('\n%% Fit this distribution to get parameter values');
[censname,freqname] = getcensfreqname(ds,exprlist,arglist);
shortform = isempty(censname) & isempty(freqname);

% Exclude data if necessary
if ~isempty(ft.exclusionrule)
   [blkf,yname,censname,freqname] = applyexclusion(blkf,ft.exclusionrule,...
                                                   yname,censname,freqname);
end

% Prepare data for fitting
[blkf,yname,censname,freqname] = ...
       writedatapreplines(blkf,yname,censname,freqname);

% Helpful note about using old results instead of fitting new data
if isequal(getfittype(ft),'param')
    blkf{end+1} = sprintf('%% To use parameter estimates from the original fit:');
    blkf{end+1} = sprintf('%%     p_ = %s;', cell2text(num2cell(ft.params)));
end

nparams = length(dist.pnames);

fname = func2str(dist.fitfunc);
onpath = exist(fname,'file');

prequired = ft.params(dist.prequired == 1); % binomial N, generalized Pareto threshold
if isequal(dist.code,'generalized pareto')
     yname = sprintf('(%s - %g)', yname, prequired);
end

if onpath && (shortform || dist.censoring)
    % Call function directly if it is on the path, and either there are no
    % censoring/weight variables, or it supports them
    if shortform
       arglist = sprintf('%s, %g',yname,alpha);
    else
       arglist = sprintf('%s, %g, %s, %s',yname,alpha,censname,freqname);
    end
    rhs = sprintf('%s(%s);',fname,arglist);
else
    % Call through MLE otherwise
    if shortform
       arglist = sprintf('%s, ''dist'',''%s'', ''alpha'',%g', ...
                         yname,dist.code,alpha);
    else
       arglist = sprintf(...
           '%s, ''dist'',''%s'', ''alpha'',%g, ''cens'',%s, ''freq'',%s', ...
                         yname,dist.code,alpha,censname,freqname);
    end
    % For the binomial distribution, which is never "onpath" because we use
    % a local fitting function to handle vector fits, we need to include
    % the value of the N parameter
    if isequal(dist.code,'binomial')
        blkf{end+1} = '% Change the ''ntrials'' parameter below to fit a different binomial';
        arglist = sprintf('%s, ''ntrials'', %d', arglist, prequired);
    end
    rhs = sprintf('mle(%s);  %% Fit %s distribution',arglist,dist.name);
end

if dist.paramvec
   blkf{end+1} = sprintf('p_ = %s',rhs);
else
   blkf{end+1} = sprintf('pargs_ = cell(1,%d);',nparams);
   blkf{end+1} = sprintf('[pargs_{:}] = %s',rhs);
   blkf{end+1} = 'p_ = [pargs_{:}];';
end

% Combine fixed and estimated parameters
if ~isempty(prequired)
   blkf{end+1} = sprintf('allp_ = zeros(1,%d); % combine fixed and estimated parameters',...
                         length(dist.prequired));
   blkf{end+1} = sprintf('allp_([%s]) = [%s];', ...
                         num2str(find(dist.prequired)), num2str(prequired));
   blkf{end+1} = sprintf('allp_([%s]) = p_;', ...
                         num2str(find(~dist.prequired)));
   blkf{end+1} = 'p_ = allp_;';
end

pargs = 'p_(1)';
if nparams>1
   pargs = [pargs, sprintf(', p_(%d)',2:nparams)];
end

% Get covariance matrix if we need confidence bounds
if ft.showbounds && ismember(ftype,{'cdf' 'survivor' 'cumhazard' 'icdf'})
   showbounds = true;
else
   showbounds = false;
end

% Sometimes we need the structure that describes the distribution
if ~onpath && (showbounds || isequal(ftype,'probplot'))
   blkf{end+1} = sprintf(...
          '\n%% Get a description of the %s distribution',...
          dist.name);
   blkf{end+1} = sprintf(...
          'dist_ = dfswitchyard(''dfgetdistributions'',''%s'');\n',...
          dist.code);
end

if showbounds
   if onpath
      blkf{end+1} = sprintf('[NlogL_,pcov_] = %s(p_,%s,%s,%s);',...
                            func2str(dist.likefunc),yname, censname, freqname);
   else
      blkf{end+1} = sprintf(...
          '[NlogL_,pcov_] = feval(dist_.likefunc,p_,%s,%s,%s);',...
          yname, censname, freqname);
   end
end

% If we supported distributions with bounds and required parameters, we'd
% have to expand pcov here to include the required (fixed) parameters

% Plot the fit and bounds if the original figure had them plotted
if isempty(ft.line) || ~ishghandle(ft.line)
   blkf{end+1} = '% This fit does not appear on the plot';
   onplot = false;
   return;
end

propvals = get(ft.line,allprop);
[c,m,l,w,s] = deal(propvals{:});

switch(ftype)
 case {'pdf'}
   if anycontinuous && anydiscrete
      if ft.iscontinuous
         blkf{end+1} = 'x_ = xc_;';
      else
         blkf{end+1} = 'x_ = xd_;';
      end            
   end
   if onpath
      blkf{end+1} = sprintf('y_ = %s(x_,%s);',func2str(dist.pdffunc),pargs);
   else
      blkf{end+1} = sprintf('y_ = pdf(''%s'',x_,%s);',dist.code,pargs);
   end
   
   blkf{end+1} = sprintf('h_ = plot(x_,y_,''Color'',[%g %g %g],...',...
                         c(1),c(2),c(3));
   blkf{end+1} = sprintf('          ''LineStyle'',''%s'', ''LineWidth'',%d,...',l,w);
   blkf{end+1} = sprintf('          ''Marker'',''%s'', ''MarkerSize'',%d);',m,s);
  
 case {'cdf' 'survivor' 'cumhazard' 'icdf'}
   if isequal(ftype,'icdf')
      if onpath
         prefix = sprintf('%s(',func2str(dist.invfunc));
      else
         prefix = sprintf('icdf(''%s'',',dist.code);
      end
   else
      if onpath
         prefix = sprintf('%s(',func2str(dist.cdffunc));
      else
         prefix = sprintf('cdf(''%s'',',dist.code);
      end
   end

   if showbounds
      blkf{end+1} = sprintf('[y_,yL_,yU_] = %sx_,%s,pcov_,%g); %% cdf and bounds',...
                            prefix,pargs,alpha);
   else
      blkf{end+1} = sprintf('y_ = %sx_,%s); %% compute cdf',...
                            prefix,pargs);
   end

   if isequal(ftype,'survivor')
      blkf{end+1} = 'y_ = 1 - y_; % convert to survivor function';
      if showbounds
         blkf{end+1} = 'tmp_ = yL_;';
         blkf{end+1} = 'yL_ = 1 - yU_;';
         blkf{end+1} = 'yU_ = 1 - tmp_;';
      end
   elseif isequal(ftype,'cumhazard')
      blkf{end+1} = 't_ = (y_ < 1); % only where the hazard is finite';
      blkf{end+1} = 'x_ = x_(t_);';
      blkf{end+1} = 'y_ = -log(1 - y_(t_));';
      if showbounds
         blkf{end+1} = 'if ~isempty(yL_)';
         blkf{end+1} = '   tmp_ = yL_;';
         blkf{end+1} = '   yL_ = -log(1 - yU_(t_));';
         blkf{end+1} = '   yU_ = -log(1 - tmp_(t_));';
         blkf{end+1} = 'end';
      end
   end
      
   blkf{end+1} = sprintf('h_ = plot(x_,y_,''Color'',[%g %g %g],...',...
                         c(1),c(2),c(3));
   blkf{end+1} = sprintf('          ''LineStyle'',''%s'', ''LineWidth'',%d,...',l,w);
   blkf{end+1} = sprintf('          ''Marker'',''%s'', ''MarkerSize'',%d);',m,s);

   if showbounds
      blkf{end+1} = 'if ~isempty(yL_)';
      blkf{end+1} = sprintf('   hb_ = plot([x_(:); NaN; x_(:)], [yL_(:); NaN; yU_(:)],''Color'',[%g %g %g],...',...
                            c(1),c(2),c(3));
      blkf{end+1} = '             ''LineStyle'','':'', ''LineWidth'',1,...';
      blkf{end+1} = '             ''Marker'',''none'');';
      blkf{end+1} = 'end';
   end

 case 'probplot'
   if onpath
      stmt = sprintf('h_ = probplot(ax_,@%s,p_);', ...
                     func2str(dist.cdffunc));
   else
      stmt = 'h_ = probplot(ax_,dist_.cdffunc,p_);';
   end
   blkf{end+1} = stmt;
   blkf{end+1} = sprintf('set(h_,''Color'',[%g %g %g],''LineStyle'',''%s'', ''LineWidth'',%d);', ...
         c(1),c(2),c(3),l,w);
end


% ---------------- write code for nonparametric fit
function [blkf,onplot] = ...
    writenpfit(blkf,ft,alpha,allprop,anycontinuous,anydiscrete,exprlist,arglist)

ds = ft.ds;
yname = expression2name(ds.yname,exprlist,arglist);
ftype = ft.ftype;

[censname,freqname] = getcensfreqname(ds,exprlist,arglist);
shortform = isempty(censname) & isempty(freqname);
   
% Exclude data if necessary
if ~isempty(ft.exclusionrule)
   [blkf,yname,censname,freqname] = applyexclusion(blkf,ft.exclusionrule,...
                                                   yname,censname,freqname);
end

% Prepare data for fitting
[blkf,yname,censname,freqname] = ...
       writedatapreplines(blkf,yname,censname,freqname);

kernel = sprintf('''%s''',ft.kernel);
if ft.bandwidthradio == 0
   width = '[]';
else
   width = ft.bandwidthtext;
end
if ischar(ft.support)
   spt = sprintf('''%s''',ft.support);
else
   spt = sprintf('[%g, %g]',ft.support);
end

% Plot the fit and bounds if the original figure had them plotted
if isempty(ft.line) || ~ishghandle(ft.line)
   blkf{end+1} = '% This fit does not appear on the plot';
   onplot = false;
   return;
end
onplot = true;

propvals = get(ft.line,allprop);
[c,m,l,w,s] = deal(propvals{:});

switch(ftype)
 case {'pdf' 'icdf' 'cdf' 'survivor' 'cumhazard'}
   if isequal(ftype,'pdf') && anycontinuous && anydiscrete
      blkf{end+1} = 'x_ = xc_;';
   end

   blkf{end+1} = sprintf('y_ = ksdensity(%s,x_,''kernel'',%s,...',...
                         yname,kernel);
   if ~shortform
      blkf{end+1} = sprintf('               ''cens'',%s,''weight'',%s,...',...
                         censname,freqname);
   end

   if ~isequal(ft,'unbounded')
      blkf{end+1} = sprintf('               ''support'',%s,...',spt);
   end
   if ~isequal(width,'[]')
      blkf{end+1} = sprintf('               ''width'',%s,...',width);
   end      
   
   blkf{end+1} = sprintf('               ''function'',''%s'');',ftype);
   blkf{end+1} = sprintf('h_ = plot(x_,y_,''Color'',[%g %g %g],...',...
                         c(1),c(2),c(3));
   blkf{end+1} = sprintf('          ''LineStyle'',''%s'', ''LineWidth'',%d,...',l,w);
   blkf{end+1} = sprintf('          ''Marker'',''%s'', ''MarkerSize'',%d);',m,s);
  

 case 'probplot'
   blkf{end+1} = sprintf('npinfo_ = {%s %s %s %s %s %s};',...
                         yname,censname,freqname,spt,kernel,width);

   blkf{end+1} = 'h_ = probplot(ax_,@cdfnp,npinfo_);';
   blkf{end+1} = sprintf('set(h_,''Color'',[%g %g %g],''LineStyle'',''%s'', ''LineWidth'',%d);', ...
         c(1),c(2),c(3),l,w);
end


% --------------- write code for data set
function [blkc,blkd,exprlist,arglist,showbounds,onplot] = ...
                 writedset(blkc,blkd,ds,exprlist,arglist,allprop,alpha)

dsname = ds.name;
yname = ds.yname;
[censname,freqname] = getcensfreqname(ds);
originalnames = {yname censname freqname};
ftype = ds.ftype;
showbounds = false;
onplot = true;

% Create comment text associating dataset with variable names
blkc{end+1} = ' ';
blkc{end+1} = sprintf('%% Data from dataset "%s":',dsname);

% Each non-empty variable name becomes a function argument,
% except expressions that are not valid variable names have
% to be replaced by a variable name that we will select here
descrtext = {'Y' 'Censoring' 'Frequency'};
for j=1:3
   exprj = originalnames{j};
   if isempty(exprj)
      continue;
   end

   % If we know the original expression, look up its index in our list
   exprnum = strmatch(exprj,exprlist,'exact');
   if isempty(exprnum);
      exprnum = length(exprlist) + 1;
      exprlist{exprnum} = exprj;
      if isvarname(exprj)
         namej = exprj;
      else
         namej = sprintf('arg_%d',exprnum);
      end
      arglist{exprnum} = namej;
   else
      namej = arglist{exprnum};
   end
   if isequal(namej,exprj) || isequal(1, strfind(exprj,'$GENERATED NAME$'))
      suffix = '';
   else
      suffix = sprintf(' (originally %s)',exprj);
   end

   blkc{end+1} = sprintf('%%    %s = %s%s',descrtext{j},namej,suffix);
   originalnames{j} = namej;
end

yname = originalnames{1};
censname = originalnames{2};
freqname = originalnames{3};
havecens = ~isempty(censname);
havefreq = ~isempty(freqname);

% Create code to plot this dataset into the figure we have created
blkd{end+1} = sprintf('%% --- Plot data originally in dataset "%s"',dsname);
[blkd,yname,censname,freqname] = ...
                           writedatapreplines(blkd,yname,censname,freqname);

dsline = ds.line;
if isempty(dsline) || ~ishghandle(dsline)
   blkd{end+1} = '% This dataset does not appear on the plot';
   onplot = false;
   return;
end

propvals = get(dsline,allprop);
[c,m,l,w,s] = deal(propvals{:});
switch(ftype)
 case 'pdf'
   % Generate code to compute the empirical cdf
   blkd{end+1} = sprintf('[F_,X_] = ecdf(%s,''Function'',''cdf''...', yname);
   if havecens
      blkd{end+1} = sprintf('               ,''cens'',%s...',censname);
   end
   if havefreq
      blkd{end+1} = sprintf('               ,''freq'',%s...',freqname);
   end
   blkd{end+1} = '              );  % compute empirical cdf';

   % Generate code to duplicate the current histogram bin width selection
   bininfo = ds.binDlgInfo;
   if isempty(bininfo)           % use default in case this is empty
      bininfo.rule = 1;
   end
   blkd{end+1} = sprintf('Bin_.rule = %d;', bininfo.rule);

   switch bininfo.rule
    case 3
      blkd{end+1} = sprintf('Bin_.nbins = %d;',bininfo.nbins);

    case 5
      blkd{end+1} = sprintf('Bin_.width = %g;',bininfo.width);
      blkd{end+1} = sprintf('Bin_.placementRule = %d;',bininfo.placementRule);
      if bininfo.placementRule ~= 1
         blkd{end+1} = sprintf('Bin_.anchor = %g;',bininfo.anchor);
      end
   end
   
   blkd{end+1} = sprintf('[C_,E_] = dfswitchyard(''dfhistbins'',%s,%s,%s,Bin_,F_,X_);',...
                         yname,censname,freqname);

   % Generate code to produce the histogram
   blkd{end+1} = '[N_,C_] = ecdfhist(F_,X_,''edges'',E_); % empirical pdf from cdf';
   blkd{end+1} = 'h_ = bar(C_,N_,''hist'');';
   blkd{end+1} = sprintf('set(h_,''FaceColor'',''none'',''EdgeColor'',[%g %g %g],...', ...
                         c(1),c(2),c(3));
   blkd{end+1} = sprintf('       ''LineStyle'',''%s'', ''LineWidth'',%d);', ...
         l,w);
   blkd{end+1} = 'xlabel(''Data'');';
   blkd{end+1} = 'ylabel(''Density'')';
  
 case {'cdf' 'survivor' 'cumhazard'}
   showbounds = ds.showbounds;
   if showbounds
      blkd{end+1} = sprintf('[Y_,X_,yL_,yU_] = ecdf(%s,''Function'',''%s'',''alpha'',%g...',...
                            yname, ftype,alpha);
   else
      blkd{end+1} = sprintf('[Y_,X_] = ecdf(%s,''Function'',''%s''...',...
                            yname, ftype);
   end
   blkd = addcensfreq(blkd,censname,freqname);
   blkd{end+1} = '              );  % compute empirical function';
   blkd{end+1} = 'h_ = stairs(X_,Y_);';
   blkd{end+1} = sprintf('set(h_,''Color'',[%g %g %g],''LineStyle'',''%s'', ''LineWidth'',%d);', ...
         c(1),c(2),c(3),l,w);
   if showbounds
      blkd{end+1} = '[XX1_,YY1_] = stairs(X_,yL_);';
      blkd{end+1} = '[XX2_,YY2_] = stairs(X_,yU_);';
      blkd{end+1} = 'hb_ = plot([XX1_(:); NaN; XX2_(:)], [YY1_(:); NaN; YY2_(:)],...';
      blkd{end+1} = sprintf('   ''Color'',[%g %g %g],''LineStyle'','':'', ''LineWidth'',1);', ...
         c(1),c(2),c(3));
   end
   blkd{end+1} = 'xlabel(''Data'');';
   switch(ftype)
      case 'cdf',       blkd{end+1} = 'ylabel(''Cumulative probability'')';
      case 'survivor',  blkd{end+1} = 'ylabel(''Survivor function'')';
      case 'cumhazard', blkd{end+1} = 'ylabel(''Cumulative hazard'')';
   end

 case 'icdf'
   blkd{end+1} = sprintf('[Y_,X_] = ecdf(%s,''Function'',''cdf''...', yname);
   blkd = addcensfreq(blkd,censname,freqname);
   blkd{end+1} = '              );  % compute empirical cdf';
   blkd{end+1} = 'h_ = stairs(Y_,[X_(2:end);X_(end)]);';
   blkd{end+1} = sprintf('set(h_,''Color'',[%g %g %g],''LineStyle'',''%s'', ''LineWidth'',%d);', ...
         c(1),c(2),c(3),l,w);
   blkd{end+1} = 'xlabel(''Probability'');';
   blkd{end+1} = 'ylabel(''Quantile'')';

 case 'probplot'
   if isempty(censname)
      censname = '[]';
   end
   if isempty(freqname)
      freqname = '[]';
   end
   blkd{end+1} = sprintf('h_ = probplot(ax_,%s,%s,%s,''noref''); %% add to probability plot', ...
                         yname,censname,freqname);
   blkd{end+1} = sprintf('set(h_,''Color'',[%g %g %g],''Marker'',''%s'', ''MarkerSize'',%d);', ...
         c(1),c(2),c(3),m,s);
   blkd{end+1} = 'xlabel(''Data'');';
   blkd{end+1} = 'ylabel(''Probability'')';
end


% -----------------------------
function [blkf,yname,censname,freqname]=applyexclusion(blkf,exclrule,...
                                                       yname,censname,freqname)
%APPLYEXCLUSION Change var names to use indexing to apply exclusion rule

% Create expressions for inclusion rules
if isempty(exclrule.ylow)
   e1 = '';
else
   ylow = str2double(exclrule.ylow);
   if exclrule.ylowlessequal==0
      e1 = sprintf('%s > %g', yname, ylow);
   else
      e1 = sprintf('%s >= %g', yname, ylow);
   end
end
if isempty(exclrule.yhigh)
   e2 = '';
else
   yhigh = str2double(exclrule.yhigh);
   if exclrule.yhighgreaterequal==0
      e2 = sprintf('%s < %g', yname, yhigh);
   else
      e2 = sprintf('%s <= %g', yname, yhigh);
   end
end

% Combine exclusion expressions
if isempty(e1)
   if isempty(e2)
      etxt = '';
   else
      etxt = e2;
   end
else
   if isempty(e2)
      etxt = e1;
   else
      etxt = sprintf('%s & %s',e1,e2);
   end
end

% Create code to generate index vector and reduce all variables
if ~isempty(etxt)
   blkf{end+1} = sprintf('\n%% Create vector for exclusion rule ''%s''',...
                         exclrule.name);
   blkf{end+1} =         '% Vector indexes the points that are included';
   blkf{end+1} = sprintf('excl_ = (%s);\n', etxt);

   blkf{end+1} = sprintf('Data_ = %s(excl_);',yname);
   yname = 'Data_';
   if ~isempty(censname) && ~isequal(censname,'[]')
      blkf{end+1} = sprintf('Cens_ = %s(excl_);',censname);
      censname = 'Cens_';
   end
   if ~isempty(freqname) && ~isequal(freqname,'[]')
      blkf{end+1} = sprintf('Freq_ = %s(excl_);',freqname);
      freqname = 'Freq_';
   end
end

% -----------------------------------------
function [censname,freqname] = getcensfreqname(ds,exprlist,arglist)
%GETCENSFREQNAME Get censoring and frequency names

censname = ds.censname;
freqname = ds.freqname;
if strcmp(censname,'(none)')
   censname = '';
end
if strcmp(freqname,'(none)')
   freqname = '';
end

if isempty(censname) && ~isempty(ds.censored)
   % We have a censoring expression, so create a fake non-empty name
   censname = sprintf('$GENERATED NAME$ %s %s',ds.name,'censored');
end
if isempty(freqname) && ~isempty(ds.frequency)
   % We have a frequency expression, so create a fake non-empty name
   freqname = sprintf('$GENERATED NAME$ %s %s',ds.name,'frequency');
end

if nargin>=3
   censname = expression2name(censname,exprlist,arglist);
   freqname = expression2name(freqname,exprlist,arglist);
end
   
  
% -------------------------------------------
function nm = expression2name(expr,exprlist,arglist)
%EXPRESSION2NAME Find out what name we're using in place of this expression

nm = expr;
if ~isempty(expr)
   j = strmatch(expr,exprlist,'exact');
   if isscalar(j)
      nm = arglist{j};
   end
end


% -------------------------------------------
function [blkd,yname,censname,freqname] = ...
                        writedatapreplines(blkd,yname,censname,freqname)
%WRITEDATAPREPLINES Write code to prep data for fitting or plotting

docens = ~isempty(censname) && ~isequal(censname,'[]');
dofreq = ~isempty(freqname) && ~isequal(freqname,'[]');

% Write a line to detect non-missing data
nanline = sprintf('t_ = ~isnan(%s)', yname);
if docens
   nanline = sprintf('%s & ~isnan(%s)', nanline, censname);
end
if dofreq
   nanline = sprintf('%s & ~isnan(%s)', nanline, freqname);
end
blkd{end+1} = sprintf('%s;', nanline);

% Write lines to remove missing data and change var names
blkd{end+1} = sprintf('Data_ = %s(t_);',yname);
yname = 'Data_';
if isempty(censname)
   censname = '[]';
elseif docens
   blkd{end+1} = sprintf('Cens_ = %s(t_);',censname);
   censname = 'Cens_';
end
if isempty(freqname)
   freqname = '[]';
elseif dofreq
   blkd{end+1} = sprintf('Freq_ = %s(t_);',freqname);
   freqname = 'Freq_';
end
