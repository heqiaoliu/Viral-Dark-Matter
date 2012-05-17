function addToolsMenus(h,f)

% Copyright 2005-2008 The MathWorks, Inc.

%% Adds tools menus for this plot type. Overloading this method lets
%% non-timeplots exclude irrelevant Tools menus

%% Get the tools menu
mtools = findobj(allchild(f),'type','uimenu','Tag','figMenuTools');

%% Add 'Merge/resample...' menu
uimenu('Parent',mtools,'Label','Resample Data...','Callback',...
    @(es,ed) tsguis.mergedlg(h),'Separator','on');
%% Add Preprocess data...' menu
mpreproc = uimenu('Parent',mtools,'Label','Process Data');
uimenu('Parent',mpreproc,'Label','Remove Missing Data...','Callback',...
    {@localPreproc h 4});
uimenu('Parent',mpreproc,'Label','Detrend....','Callback',...
    {@localPreproc h 1});
uimenu('Parent',mpreproc,'Label','Filter...','Callback',...
    {@localPreproc h 2});
uimenu('Parent',mpreproc,'Label','Interpolate...','Callback',...
    {@localPreproc h 3});

%--------------------------------------------------------------------------
function localPreproc(eventSrc,eventData,this,Ind)


RS = tsguis.preprocdlg(this);
set(RS.Handles.TABGRPpreproc,'SelectedIndex',Ind);