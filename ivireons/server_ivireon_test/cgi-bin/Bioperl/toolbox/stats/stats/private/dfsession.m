function ok=dfsession(action,fn)
%DFSESSION Clear, load, or save a Distribution Fitting session

%   $Revision: 1.1.8.4 $  $Date: 2010/05/10 17:59:47 $
%   Copyright 2003-2010 The MathWorks, Inc.

% Create a structure with version information
str.ftype = 'Distribution Fitting session';   % type of file
str.version = 1;                              % the most current version
str.allversions = [1];                        % all supported versions
str.properties = {'Color' 'LineStyle' 'LineWidth' 'Marker' 'MarkerSize'};

% Variables we save, and the number required to be in a saved file
varnames = {'ftype' 'version' 'allds' 'dsinfo' 'allfits' ...
            'fitinfo' 'alldists' 'outliers' 'guistate'};
nrequired = 9;

if nargin<2
   fn = '';
end

% Turn off legend before loading; loaded session may turn it back on
oldleg = dfgetset('showlegend');
if isequal(oldleg,'on') && isequal(action,'load')
   dfgetset('showlegend','off');
end

ok = true;
switch(action)
 case 'save'
   ok = savesession(fn,str,varnames);

 case 'load'
   ok = loadsession(fn,str,varnames,nrequired,oldleg);

 case 'clear'
   ok = clearsession;

 otherwise
   ok = false;
end

% Session is no longer dirty (in need of saving) if we succeeded
if ok
   dfgetset('dirty',false);
end


% ----------------------------------------------------------------
function ok=savesession(fn,str,varnames)
%DFSAVESESSION Callback to save a distribution fitting session to a file

% Extract some variables from the input structure
ftype = str.ftype;
version = str.version;
guistate.ftype = dfgetset('ftype');
guistate.dtype = dfgetset('dtype');
guistate.binDlgInfo = dfgetset('binDlgInfo');
guistate.conflev = dfgetset('conflev');
guistate.showlegend = dfgetset('showlegend');
if isequal(guistate.showlegend,'on')
   dffig = dfgetset('dffig');
   ax = findall(dffig,'Type','axes','Tag','main');
   legh = legend(ax);
   if isscalar(legh)
       guistate.legrelpos = getrelativelegendposition(dffig,ax,legh);
   end
   guistate.leginfo = dfgetlegendinfo(legh);
end

% Get all M data set object instances and some properties
dsdb = getdsdb;
allds = find(dsdb);
allds(allds==dsdb) = [];
nds = length(allds);
dsinfo = cell(nds,1);
for j=1:length(allds)
   % Save all datasets
   dj = allds(j);
   dsinfo{j,1} = dj.plot;    % remember this flag separately from object
end

% Get all M fit object instances and some properties
fitdb = getfitdb;
allfits = find(fitdb);
allfits(allfits==fitdb) = [];
nfits = length(allfits);
fitinfo = cell(nfits,1);
for j=1:nfits
   % Save all fit objects separately
   fj = allfits(j);
   fitinfo{j,1} = fj.plot;  % remember this flag separately from object
end

% get the user-defined distributions
alldists = dfgetset('alldistributions');

% Get the outliers (excluded sets)
outdb = getoutlierdb;
outliers = find(outdb);
outliers(outliers==outdb) = [];

% Get file name to use, remember the directory name
olddir = dfgetset('dirname');
filespec = [olddir '*.dfit'];
if isempty(fn)
   [fn,pn] = uiputfile(filespec,'Save Session');
   if isequal(fn,0) || isequal(pn,0)
      ok = false;
      return
   end
   if ~ismember('.',fn)
      fn = [fn '.dfit'];
   end
   dfgetset('dirname',pn);
   fn = [pn fn];
end

% Select a file and save the session variables
try
   save(fn, varnames{:}, '-mat');
catch ME
   uiwait(errordlg(sprintf('Error saving session file:\n%s', ME.message),...
                   'Save Error','modal'))
   ok = false;
   return
end
ok = true;
   
% ----------------------------------------------------------------
function ok=loadsession(fn,str,varnames,nrequired,oldleg)
%DFLOADSESSION Callback to load a saved distribution fitting session
   
import com.mathworks.toolbox.stats.*;

ok = true;
ftype = str.ftype;
allversions = str.allversions;

% Get file name and load from it, remember the directory name
olddir = dfgetset('dirname');
filespec = [olddir '*.dfit'];

if isempty(fn)
   [fn,pn] = uigetfile(filespec,'Load Session');
   if isequal(fn,0) || isequal(pn,0)
      return
   end
   if ~ismember('.',fn)
      fn = [fn '.dfit'];
   end
   dfgetset('dirname',pn);
   fn = [pn fn];
end

% Clear current session
clearsession;

% Get file contents without adding them to the data bases automatically
dsmgr = DataSetsManager.getDataSetsManager;
fmgr = FitsManager.getFitsManager;
dsmgr.turnOffUDDListener;
fmgr.turnOffUDDListener;
try
   s = load('-mat',fn);
catch ME
   uiwait(errordlg(sprintf('Error loading session file:\n%s', ME.message),...
                   'Load Error','modal'))
   dsmgr.turnOnUDDListener;
   return
end
dsmgr.turnOnUDDListener;
fmgr.turnOnUDDListener;

for j=1:nrequired
   if ~isfield(s,varnames{j})
      uiwait(errordlg('Not a valid Distribution Fitting session file',...
                   'File Invalid','modal'))
      return
   end
end
if ~isequal(s.ftype,ftype)
   uiwait(errordlg('Not a valid Distribution Fitting session file',...
                   'File Invalid','modal'))
   return
end

if ~ismember(s.version,allversions)
   uiwait(errordlg('Bad version number in Distribution Fitting session file',...
                   'Invalid Version','modal'))
   return
end

% Install the saved distribution definitions
dft = DistributionFitting.getDistributionFitting;
try
   olddists = dfgetset('alldistributions');
   newdists = mergedistributions(olddists,s.alldists);
   allnames = {newdists.name};
   [~,sortidx] = sort(allnames);
   newdists = newdists(sortidx);
   dfsetdistributions(dft,newdists);
catch ME
   uiwait(errordlg(sprintf('Error loading saved session:\n%s',ME.message),...
                   'File Invalid','modal'));
end

% Reset some properties of the gui state
dffig = dfgetset('dffig');
oldconflev = dfgetset('conflev');
dfsetplottype(dffig, s.guistate.ftype, s.guistate.dtype);
if isfield(s.guistate,'binDlgInfo')
   dfgetset('binDlgInfo',s.guistate.binDlgInfo);
end

hFunctionList = findall(dffig, 'Tag', 'displaylist');
ftypes = getappdata(hFunctionList,'codenames');
value = strmatch(s.guistate.ftype, ftypes, 'exact');
set(hFunctionList, 'Value', value);

isprobplot = isequal(s.guistate.ftype, 'probplot');
if isprobplot
   hDistributionList = findall(dffig, 'Tag', 'typelist');
   dtypes = getappdata(hDistributionList,'okcodenames');
   value = strmatch(s.guistate.dtype, dtypes, 'exact');
   set(hDistributionList, 'Value', value);
end
if isfield(s.guistate,'conflev')
   conflev = s.guistate.conflev;
else
   conflev = oldconflev;
end

% Make sure distribution list is accurate
dfupdateppdists(dffig);

% Plot datasets that are flagged for plotting
for j=1:length(s.allds);
   dj = s.allds(j);

   % Now set the plot flag.  Some non-serializable information
   % (line handles, listeners, etc.) will be re-created at this point.
   dj.line = [];
   if s.dsinfo{j}
      dj.plot = 1;
   end
   dsmgr.addDataSet(java(dj), dj.name);
end

% Get exclusion rules (outliers)
omgr = OutliersManager.getOutliersManager;
omgr.init;

% Fix up fit objects
fitdb = getfitdb;
outdb = getoutlierdb;
for j=1:length(s.allfits)
   fj = s.allfits(j);
   
   if isempty(fj.version)
       fj.version = 1;  % original definition had no version number
   end

   % Restore all dataset handles
   dsname = fj.dataset;
   for k=1:length(s.allds)
      if isequal(dsname,s.allds(k).name)
         fj.dshandle = s.allds(k);
         break;
      end
   end

   % Restore all exclusion rule handles
   ername = fj.exclusionrulename;
   if ~isempty(ername)
      erhandle = find(outdb,'name',ername);
      fj.exclusionrule = erhandle;
   end
   
   % Connect this fit to the fit data base and add to fits manager
   connect(fj,fitdb,'up');

   % Now set the plot flag.  Some non-serializable information
   % (line handles, listeners, etc.) will be re-created at this point.
   fj.line = [];
   if s.fitinfo{j,1}
      fj.plot = 1;
   end
end

% Update the fits if necessary for a new confidence level
if ~isequal(conflev,oldconflev)
   % Set the new level as the current level.  Items loaded are based
   % on that level, so there's no need to update them.
   dfgetset('conflev',conflev);

   % Update the menu setting
   dfsetconflev(dffig,conflev);
end

% Legends and their positions
if ~isfield(s.guistate,'showlegend')
   s.guistate.showlegend = oldleg;
end
if ~isfield(s.guistate,'leginfo')
   s.guistate.leginfo = {};
end
dftogglelegend(dffig,s.guistate.showlegend,s.guistate.leginfo);
if isequal(s.guistate.showlegend,'on')
   if isfield(s.guistate,'legrelpos')
      ax = findall(dffig,'Type','axes','Tag','main');
      if isscalar(ax)
         setrelativelegendposition(s.guistate.legrelpos,dffig,ax);
      end
   end
end

% ----------------------------------------------------------------
function ok=clearsession
%DFCLEARSESSION Callback to clear distribution fitting session

ok = true;

% Trigger java listeners to clear all saved java content
import com.mathworks.toolbox.stats.*;
DFToolClearManager.getDFToolClearManager.listenerTrigger;

% Delete all udd fit object instances
fitdb = getfitdb;
ft = down(fitdb);
while(~isempty(ft))
   ftnew = right(ft);
   delete(ft);
   ft = ftnew;
end

% Delete all udd data set object instances
dsdb = getdsdb;
dj = down(dsdb);
while(~isempty(dj))
   if dj.plot
      dj.plot = 0;
   end
   djnew = right(dj);
   delete(dj);
   dj = djnew;
end

% Delete all udd outlier object instances
outdb = getoutlierdb;
outliers = find(outdb);
outliers(outliers==outdb) = [];
delete(outliers);

% ----------------------------------
function dnew = mergedistributions(d1,d2)
% Get merge current distributions d1 and value from file d2

dnew = d1;

% Fill defaults into version read from file
for j=1:numel(d2)
    d2j = dfprobspecdefaults(d2(j));
    flds = fieldnames(d2j);
    for k=1:numel(flds)
        % Assign fields; different field names may prevent assigning struct
        d2(j).(flds{k}) = d2j.(flds{k});
    end
end

names1 = {d1.code};  % code names currently defined
names2 = {d2.code};  % code names read from file

% Old struct may not have all the fields that the new one has, so assign
% them one by one
t = ~ismember(names2,names1);
if any(t)
    fields = fieldnames(d2);
    for j=find(t)
        row = numel(dnew)+1;
        for k=1:length(fields)
           fn = fields{k};
           dnew(row).(fn) = d2(j).(fn);
        end
    end
end

