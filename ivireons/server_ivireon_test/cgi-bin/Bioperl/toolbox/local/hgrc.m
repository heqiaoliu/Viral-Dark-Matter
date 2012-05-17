%HGRC Master startup MATLAB file for Handle Graphics.
%   HGRC is automatically executed by MATLAB during startup.
%   It establishes the default figure size and sets a few uicontrol defaults.
%
%	On multi-user or networked systems, the system manager can put
%	any messages, definitions, etc. that apply to all users here.
%
%   HGRC also invokes a STARTUPHG command if the file 'startupHG.m'
%   exists on the MATLAB path.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $  $Date: 2010/02/01 02:10:19 $

% Set the default figure position, in pixels.
% On small screens, make figure smaller, with same aspect ratio.
monitors = get(0, 'MonitorPositions');
screen = monitors(1,:);
if size(monitors,1) > 1
  for i = 1:size(monitors,1)
    if monitors(i,1) < screen(1) && monitors(i,2) < screen(2)
      screen = monitors(i,:);
    end
  end
end
width = screen(3) - screen(1);
height = screen(4) - screen(2);
if any(screen(3:4) ~= 1)  % don't change default if screensize == [1 1]
  if all(cname(1:2) == 'PC')
    if height >= 500
      mwwidth = 560; mwheight = 420;
      if(get(0,'screenpixelsperinch') == 116) % large fonts
        mwwidth = mwwidth * 1.2;
        mwheight = mwheight * 1.2;
      end
    else
      mwwidth = 560; mwheight = 375;
    end
    left = screen(1) + (width - mwwidth)/2;
    bottom = height - mwheight -100 - screen(2);
  else
    if height > 768
      mwwidth = 560; mwheight = 420;
      left = screen(1) + (width-mwwidth)/2;
      bottom = height-mwheight -100 - screen(2);
    else  % for screens that aren't so high
      mwwidth = 512; mwheight = 384;
      left = screen(1) + (width-mwwidth)/2;
      bottom = height-mwheight -76 - screen(2);
    end
  end
  % round off to the closest integer.
  left = floor(left); bottom = floor(bottom);
  mwwidth = floor(mwwidth); mwheight = floor(mwheight);

  rect = [ left bottom mwwidth mwheight ];
  set(0, 'DefaultFigurePosition',rect);
end

if ~feature('HGUsingMatlabClasses')
    colordef(0,'white') % Set up for white defaults
end

%% Uncomment the next group of lines to make uicontrols, uimenus
%% and lines look better on monochrome displays.
%if get(0,'ScreenDepth')==1,
%   set(0,'DefaultUIControlBackgroundColor','white');
%   set(0,'DefaultAxesLineStyleOrder','-|--|:|-.');
%   set(0,'DefaultAxesColorOrder',[0 0 0]);
%   set(0,'DefaultFigureColor',[1 1 1]);
%end

%% Uncomment the next line to use Letter paper and inches
%defaultpaper = 'usletter'; defaultunits = 'inches'; defaultsize = [8.5 11.0];

%% actual A4 size is 21.0 x 29.7, but values below are consistent with
%%   calculations done during conversion of units. 
a4Size = [20.984041948119998  29.677431697909999];
%% Uncomment the next line to use A4 paper and centimeters
%defaultpaper = 'A4'; defaultunits = 'centimeters'; defaultsize = a4Size;

%% If neither of the above lines are uncommented then guess
%% which papertype and paperunits to use based on ISO 3166 country code.
if usejava('jvm') && ~exist('defaultpaper','var')
  if any(strncmpi(char(java.util.Locale.getDefault.getCountry), ...
		  {'gb', 'uk', 'fr', 'de', 'es', 'ch', 'nl', 'it', 'ru',...
		   'jp', 'kr', 'tw', 'cn', 'cz', 'sk', 'au', 'dk', 'fi',...
           'gr', 'hu', 'ie', 'il', 'in', 'no', 'pl', 'pt',...
           'ru', 'se', 'tr', 'za','nz','be'},2))
    defaultpaper = 'A4';
    defaultunits = 'centimeters';
    defaultsize = a4Size;
  end
end

%% Set the default if requested
if exist('defaultpaper','var') && exist('defaultunits','var') && ...
        exist('defaultsize', 'var')
  % Handle Graphics defaults
  set(0,'DefaultFigurePaperType', defaultpaper);
  set(0,'DefaultFigurePaperUnits',defaultunits);
  set(0,'DefaultFigurePaperSize', defaultsize);
end

%% For Japan, set default fonts
lang = lower(get(0,'language'));
if strncmp(lang, 'ja', 2)
   if strncmp(cname,'PC',2)
      set(0,'DefaultUIControlFontName',get(0,'FactoryUIControlFontName'));
      set(0,'DefaultUIControlFontSize',get(0,'FactoryUIControlFontSize'));
      set(0,'DefaultAxesFontName',get(0,'FactoryUIControlFontName'));
      set(0,'DefaultAxesFontSize',get(0,'FactoryUIControlFontSize'));
      set(0,'DefaultTextFontName',get(0,'FactoryUIControlFontName'));
      set(0,'DefaultTextFontSize',get(0,'FactoryUIControlFontSize'));

      %% You can control the fixed-width font
      %% with the following command
      % set(0,'fixedwidthfontname','MS Gothic');
   end
end

%% CONTROL OVER FIGURE TOOLBARS:
%% The new figure toolbars are visible when appropriate,
%% by default, but that behavior is controllable
%% by users.  By default, they're visible in figures
%% whose MenuBar property is 'figure', when there are
%% no uicontrols present in the figure.  This behavior
%% is selected by the figure ToolBar property being
%% set to its default value of 'auto'.

%% to have toolbars always on, uncomment this:
%set(0,'DefaultFigureToolbar','figure')

%% to have toolbars always off, uncomment this:
%set(0,'DefaultFigureToolbar','none')

% Clean up workspace.
clear

% Temporarily turn off old uitable deprecated function warning.
warning off MATLAB:uitable:DeprecatedFunction

% Temporarily turn off old uiflowcontainer deprecated function warning.
warning off MATLAB:uiflowcontainer:DeprecatedFunction

% Temporarily turn off old uigridcontainer deprecated function warning.
warning off MATLAB:uigridcontainer:DeprecatedFunction

% Temporarily turn off old uitab and uitabgroup deprecated function warning.
warning off MATLAB:uitab:DeprecatedFunction
warning off MATLAB:uitabgroup:DeprecatedFunction

% Temporarily turn off old uitree and uitreenode deprecated function warning.
% NOTE - matlab/toolbox/matlab/timeseries/tTstool.m, test point
% lvlTwo_handleTests, is currently checking for this warning and ignoring
% it.  When we introduce the new documented uitree to replace the old
% undocumented uitree, tTstool.m must be modified to look for this warning
% id.
warning off MATLAB:uitree:DeprecatedFunction
warning off MATLAB:uitreenode:DeprecatedFunction

% Execute startup MATLAB file, if it exists.
startup_exists = exist('startuphg','file');
if startup_exists == 2 || startup_exists == 6
    clear startup_exists
    startuphg
else
    clear startup_exists
end

