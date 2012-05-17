function varargout=dfittool(varargin)
%DFITTOOL Distribution Fitting Tool.
%   DFITTOOL opens a graphical user interface for displaying fit distributions
%   to data.  To fit distributions to your data and display them over plots
%   over plots of the empirical distributions, you can import data from the
%   workspace.
%
%   DFITTOOL(Y) displays the Distribution Fitting Tool and creates a data set
%   with data specified by the vector y.
%
%   DFITTOOL(Y,CENS) uses the vector cens to specify whether the observation
%   Y(j) is censored, (CENS(j)==1) or observed exactly (CENS(j)==0).  If
%   CENS is omitted or empty, no Y values are censored.
%
%   DFITTOOL(Y,CENS,FREQ) uses the vector FREQ to specify the frequency of
%   each element of Y.  If FREQ is omitted or empty, all Y values have a
%   frequency of 1.
%
%   DFITTOOL(Y,CENS,FREQ,'DSNAME') creates a data set with the name 'dsname'
%   using the data vector Y, censoring indicator CENS, and frequency vector
%   FREQ. 
%
%   See also MLE, DISTTOOL, RANDTOOL.

%   Copyright 2001-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:13:20 $

import com.mathworks.toolbox.stats.*;

% Handle call-back
if (nargin > 0 && ischar(varargin{1}))
    out = switchyard(varargin{:});
    if nargout>0
       varargout = {out};
    end
    return
end

% Can't proceed unless we have desktop java support
if ~usejava('swing')
    error('stats:dfittool:JavaSwingRequired',  ...
          'The Distribution Fitting Tool (dfittool) requires Java Swing to run.');
end

% Get a reference to the singleton instance of the java
% distribution fitting class
DistributionFitting.showDistributionFitting;
dft = DistributionFitting.getDistributionFitting;

% make sure there are instances of datasets and fits and outliers
DataSetsManager.getDataSetsManager;
FitsManager.getFitsManager;
OutliersManager.getOutliersManager;

% Send the gui information about the distributions we can fit
dfgetset('alldistributions','');  % clear definitions left-over from before
[dists,errid,errmsg] = dfgetdistributions;
if ~isempty(errmsg)
   edlg = errordlg(sprintf('Error trying to import custom distributions:\n%s',...
                    errmsg),...
            'Distribution Fitting Tool','modal');
else
   edlg = [];
end
dfsetdistributions(dft,dists);

dfgetset('dft',dft);

% Try to get old figure
dffig = dfgetset('dffig');

% If the handle is empty, create the object and save the handle
makefig = (isempty(dffig) || ~ishghandle(dffig));
if makefig
   dffig = dfcreateplot;
   dfsession('clear');
   dfsetfunction(dffig,'pdf');
   
   % Initialize default bin width rules information
   initdefaultbinwidthrules;
   
   dfgetset('dirty',true);   % session has changed since last save
else
   figure(dffig);
end
 
% Start with input data, or put up message about importing data
ds = [];
if nargin>0
   % If data were passed in, set up argument list for that case
   dsargs = {[] [] [] ''};
   n = min(4,nargin);
   dsargs(1:n) = varargin(1:n);
   for j=1:min(3,n)
      dsargs{4+j} = inputname(j);   % get data names if possible
   end
   [ds,err] = dfcreatedataset(dsargs{:});
   
   if ~isempty(err)
      err = sprintf('Error importing data:\n%s',err);
      errordlg(err,'Bad Input Data','modal');
   end
   dfgetset('dirty',true);   % session has changed since last save
   if ~makefig
      delete(findall(dffig,'Tag','dfstarthint')); % remove any old message
   end
end

if makefig && (nargin==0 || isempty(ds))
   text(.5,.5,xlate('Select "Data" to begin distribution fitting'),...
        'Parent',get(dffig,'CurrentAxes'),'Tag','dfstarthint',...
        'HorizontalAlignment','center');
end

if nargout==1
   varargout={dft};
end

if ~isempty(edlg)
    figure(edlg);
end

% --------------------------------------------
function out = switchyard(action,varargin)
%SWITCHYARD Dispatch menu call-backs and other actions to private functions

cbo = gcbo;
if ~isempty(cbo) && ~isa(cbo,'schema.prop')
   dffig = gcbf;
else
   dffig = [];
end
if isempty(dffig)
   dffig = dfgetset('dffig');
end
out = [];

switch(action)
    % Fitting actions
    case 'addsmoothfit'
         fit = dfaddsmoothfit(varargin{:});
         if ~isempty(fit)
             fit.fitframe.setTitle('Edit Fit');
         end
         dfupdatelegend(dffig);
         dfupdateylim;
         if ~isempty(fit)
            out = java(fit);
         end
         dfupdateppdists(dffig);
    case 'addparamfit'
         fit = dfaddparamfit(varargin{:});
         if ~isempty(fit)
             javaMethodEDT('setTitle', fit.fitframe, 'Edit Fit');
         end
         dfupdatelegend(dffig);
         dfupdateylim;
         if ~isempty(fit)
            out = java(fit);
         end
         dfupdateppdists(dffig);
    % Various graph manipulation actions
    case 'adjustlayout'
         dfadjustlayout(dffig);
         dfgetset('oldposition',get(dffig,'Position'));
         dfgetset('oldunits',get(dffig,'Units'));
    case 'defaultaxes'
         dfupdatexlim([],true,true);
         dfupdateylim(true);

    % Actions to toggle settings on or off
    case 'togglegrid'
         dftogglegrid(dffig);
    case 'togglelegend'
         dftogglelegend(dffig);
    case 'toggleaxlimctrl'
         dftoggleaxlimctrl(dffig)

    % Actions to set certain parameters
    case 'setconflev'
         if (dfsetconflev(dffig,varargin{:}))
             dfgetset('dirty',true);   % session has changed since last save
         end

    % Actions related to the session
    case 'clear session'
         delete(findall(gcbf,'Tag','dfstarthint'));
         if dfasksavesession(dffig)
            dfsession('clear');
         end
    case 'save session'
         dfsession('save');
    case 'load session'
         delete(findall(gcbf,'Tag','dfstarthint'));
         if dfasksavesession(dffig)
            dfsession('load');
         end

    % Assorted other menu actions
    case 'generate code'
         dffig2m;
    case 'clear plot'
         delete(findall(dffig,'Tag','dfstarthint'));
         dfcbkclear;
    case 'import data'
         delete(findall(dffig,'Tag','dfstarthint'));
         awtinvoke('com.mathworks.toolbox.stats.Data', 'showData');
    case 'duplicate'
         dfdupfigure(gcbf);
    case 'gettipfcn'
         out = @dftips;
end

% --------------------------------------------
function initdefaultbinwidthrules()
binDlgInfo = struct('rule', 1, 'nbinsExpr', '', 'nbins', [], 'widthExpr', '', ...
                    'width', [], 'placementRule', 1, 'anchorExpr', '', ...
                    'anchor', [], 'applyToAll', false, 'setDefault', false);
dfgetset('binDlgInfo', binDlgInfo);


