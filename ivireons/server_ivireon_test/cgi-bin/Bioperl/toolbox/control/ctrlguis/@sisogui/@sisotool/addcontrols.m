function addcontrols(sisodb)
%ADDCONTROLS  Add SISO Tool UI controls.
%
%   See also SISOTOOL.

%   Author: P. Gahinet  
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2005/11/15 00:53:04 $

sisodb.HG = struct(...
    'Configuration',[],...%configframe(sisodb),...
    'Status',LocalMakeStatus(sisodb.EventManager),... 
    'Toolbar',toolbar(sisodb),...
    'Menus',figmenus(sisodb));

%-------------------------Internal Functions-------------------------

%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalMakeStatus %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function Frame = LocalMakeStatus(EventManager)

SISOfig = EventManager.Frame;

% Geometry of separator
FigPos = get(SISOfig,'Position'); % in characters
set(SISOfig,'Units','pixel')
p = get(SISOfig,'Position');
set(SISOfig,'Units','character')
pix2char = FigPos(3:4)./p(3:4);
x = pix2char(1);  % one pixel wide
h = pix2char(2);  % one pixel high

% Create status separator
color = get(SISOfig,'Color');
lcolor = min(1,color * 1.2);
dcolor = min(1,color * .6);
Sep = [uicontrol('parent',SISOfig,'backgroundcolor',lcolor,...
      'style','text','units','character','pos',[x 0 10 1.5*h]);...
      uicontrol('parent',SISOfig,'backgroundcolor',dcolor,...
      'style','text','units','character','pos',[x 0 10 h])];

% Create status text field
StatusText = uicontrol('Parent',SISOfig,...
   'Units','character', ...
   'Style','text', ...
   'Horiz','left', ...
   'TooltipString','Status Bar',...
   'HelpTopicKey','sisostatusbar'); 
EventManager.StatusField = StatusText;

Frame = struct(... 
   'Separator',Sep,... 
   'StatusText',StatusText); 
