function dfcustomdist(~,~,action)
%DFCUSTOM Callbacks for menu items related to custom distributions

%   $Revision: 1.1.8.2 $  $Date: 2010/05/10 17:59:40 $
%   Copyright 2003-2010 The MathWorks, Inc.

fnpath = which('dfittooldists.m');
dft = com.mathworks.toolbox.stats.DistributionFitting.getDistributionFitting;

switch(action)
  % --------------------------------
  case 'clear'        % clear custom definitions, revert to standard ones
   % Ask for confirmation
   inuse = conflictingfits();
   if ~isempty(inuse)
       fitlist = sprintf(', %s',inuse{:});
       msg = sprintf( ...
         'Cannot clear custom distributions because one or more fits are using them:\n%s',...
         fitlist(3:end));
       msgbox(msg,'Clear Custom Distributions','none','modal');
       return
   end
   ok = questdlg('Clear custom distributions and revert to standard ones?',...
                 'Clear Custom Distributions',...
                 'Yes','No','Yes');
   if ~isequal(ok,'Yes')
      return;
   end
   dfgetset('alldistributions','');       % clear all distributions
   dists = dfgetdistributions('',false);  % get built-in list
   dfsetdistributions(dft,dists);         % save them as current
   showresults({dists.name},[]);
   dfgetset('dirty',true);   % session has changed since last save

  % --------------------------------
  case 'define'       % define a file of probability distribution specs
   % Determine if such a file already exists
   if isempty(fnpath)
      % None found, so start editing a new one with default contents
      fname = fullfile(matlabroot,'toolbox','stats','stats','private',...
                       'dftoolinittemplate.m');
      txt = textread(fname,'%s','whitespace','','bufsize',1e6);
      editorservices.new(txt{1});
      
      
   else
      % Edit the existing file
      edit(fnpath)
   end
   
   % Display a helpful message about what's going on
   msg = sprintf(['Define your custom distributions by editing this file and'...
                  '\nsaving it on your path with the name dfittooldists.m.'...
                  '\n\nThen use File -> Custom Distributions -> Import '...
                  '\nto import your distributions.']);
   msgbox(msg,'Define Custom Distributions','none','modal');

  % --------------------------------
  case 'import'       % import a file of probability distribution specs 
   % Remember current distributions
   olds = dfgetset('alldistributions');
   
   % Locate the file of new distribution settings
   if isempty(fnpath)
      fnpath = '*.m';
   end
   [fn,pn] = uigetfile(fnpath,'Select file of distributions to import');
   if isequal(fn,0)
      return
   end
   [~,fname,fext] = fileparts(fn);
   if ~isequal(fext,'.m')
      errordlg(sprintf(['MATLAB .m file required.\n' ...
                        'Can''t import distributions from the file %s.'],...
                       [fname fext]),...
               'Bad Selection');
      return
   end

   % Go to that file's directory and try to run it
   olddir = pwd;
   dists = olds;
   try
      cd(pn);
      [dists,~,errmsg,newrows] = dfgetuserdists(dists,fname);
   catch ME
      errmsg = ME.message;
      newrows = [];
   end
   cd(olddir);
   
   % Revert to previous distribution list if anything bad happened
   if ~isempty(errmsg)
      dists = olds;
      errordlg(sprintf('Error trying to import custom distributions:\n%s',...
                       errmsg),...
               'Import Custom Distributions','modal');
      newrows = [];
   end

   % Sort by name
   lowernames = lower(strvcat(dists.name));
   [~, ind] = sortrows(lowernames);
   dists = dists(ind);
   newrows = find(ismember(ind,newrows));

   if isempty(errmsg)
      showresults({dists.name},newrows);
   end
   dfsetdistributions(dft,dists);

   dfgetset('dirty',true);   % session has changed since last save
end

% ---------------------------------
function showresults(liststring,asterisk)
%SHOWRESULTS Stripped-down version of listdlg, just to show a list

promptstring = 'New parametric distribution list:';

if nargin>=2
   for j=1:length(asterisk)
      liststring{asterisk(j)} = sprintf('%s *',liststring{asterisk(j)});
   end
   footnote = ~isempty(asterisk);
else
   footnote = false;
end

ex = get(0,'defaultuicontrolfontsize')*1.7;  % extent height per line
fp = get(0,'defaultfigureposition');
fus = 8;       % frame/uicontrol spacing
ffs = 8;       % frame/figure spacing
uh = 22;       % uicontrol button height
listsize = [160 300];
if footnote
   footnoteheight = 2*ex;
else
   footnoteheight = 0;
end

w = 2*(fus+ffs)+listsize(1);
h = 2*ffs+6*fus+ex+listsize(2)+uh + footnoteheight;
fp = [fp(1) fp(2)+fp(4)-h w h];  % keep upper left corner fixed

figcol = get(0,'defaultUicontrolBackgroundColor');
fig_props = { ...
    'name'                   'Imported Distributions'  ...
    'color'                  figcol ...
    'resize'                 'off' ...
    'numbertitle'            'off' ...
    'menubar'                'none' ...
    'windowstyle'            'modal' ...
    'visible'                'off' ...
    'integerhandle'          'off'    ...
    'handlevisibility'       'callback' ...
    'position'               fp   ...
    'closerequestfcn'        'delete(gcbf)' ...
    'Dock'                   'off' ...
            };
fig = figure(fig_props{:});

posn = [ffs+fus     fp(4)-(ffs+fus+ex) ...
        listsize(1) ex];

uicontrol('style','text','string',promptstring,...
          'horizontalalignment','left','position',posn);

btn_wid = (fp(3)-2*(ffs+fus)-fus)/2;
liststring=cellstr(liststring);
listbox = uicontrol('style','listbox',...
                    'position',[ffs+fus ffs+uh+4*fus+footnoteheight listsize],...
                    'string',liststring,...
                    'backgroundcolor',figcol,...
                    'max',2,...
                    'tag','listbox',...
                    'value',[]);

%frameh = uicontrol('style','frame',...
%                   'position',[ffs+fus-1 ffs+fus-1 btn_wid+2 uh+2],...
%                   'backgroundcolor','k');
if footnote
   uicontrol('style','text','string',sprintf('* Imported or changed;\n  available for new fits'),...
             'horizontalalignment','left',...
             'position',[ffs+fus, ffs+fus+uh+footnoteheight/4, listsize(1), footnoteheight]);
end


ok_btn = uicontrol('style','pushbutton',...
                   'string','OK',...
                   'position',[ffs+fus+listsize(1)/2-btn_wid/2 ffs+fus btn_wid uh],...
                   'callback','delete(gcbf)');

% make sure we are on screen
placetitlebar(fig)
set(fig, 'visible','on');

% ---------------------------------
function fitname = conflictingfits()
%CONFLICTINGFITS Return cell array of fits using custom distributions

% Get a list of standard (not custom) distributions
std = dfgetdistributions('',false,false);
stdcodes = {std.code};

% Get a list of fits not based on standard distributions
fitdb = getfitdb;
fit = down(fitdb);
fitname = {};
while(~isempty(fit))
   if ~ismember(fit.distname,stdcodes)
       fitname{end+1} = fit.name;
   end
   fit = right(fit);
end
