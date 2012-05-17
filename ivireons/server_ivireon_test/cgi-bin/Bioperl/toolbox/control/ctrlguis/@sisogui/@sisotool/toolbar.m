function ToggleHandles = toolbar(sisodb)
%TOOLBAR  Builds SISO Tool toolbar and manages global edit modes.

%   Author(s): P. Gahinet
%   Revised: C. Buhr
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.16.4.3 $ $Date: 2006/11/17 13:25:58 $

% Load icon images
s = load('sisoicons');
uicolor = get(0,'defaultuicontrolbackground');
uicolor = uicolor(1);
s.rpole(isinf(s.rpole)) = uicolor;
s.cpole(isinf(s.cpole)) = uicolor;
s.rzero(isinf(s.rzero)) = uicolor;
s.czero(isinf(s.czero)) = uicolor;
s.erase(isinf(s.erase)) = uicolor;

% Create toolbar
t = uitoolbar(sisodb.Figure,'HandleVisibility','off');

% Arrow icon (default mode)
a = uitoggletool('Parent',t,...
    'Tooltip','Default mode',...
    'State','on',...
    'CData',s.arrow, ...
    'Tag', 'SISOToolArrow');

% Create toggle buttons for Pole/Zero editing
b(1) = uitoggletool('Parent',t,...
    'Tooltip','Add real pole',...
    'CData',s.rpole,'Tag','AddRealPole');
b(2) = uitoggletool('Parent',t,...
    'Tooltip','Add real zero',...
    'CData',s.rzero,'Tag','AddRealZero');
b(3) = uitoggletool('Parent',t,...
    'Tooltip','Add complex pole',...
    'CData',s.cpole,'Tag','AddComplexPole');
b(4) = uitoggletool('Parent',t,...
    'Tooltip','Add complex zero',...
    'CData',s.czero,'Tag','AddComplexZero');
b(5) = uitoggletool('Parent',t,...
    'Tooltip','Delete pole/zero',...
    'CData',s.erase,'Tag','DeletePoleZero');

% Create toggle buttons for zooming
z(1) = uitoolfactory(t,'Exploration.ZoomIn'); 
set(z(1),'Separator','on');
z(2) = uitoolfactory(t,'Exploration.ZoomOut');
z(3) = uitoolfactory(t,'Exploration.Pan');


% Create CS help button
h = uitoggletool('Parent',t,...
    'Separator','on',...
    'Tooltip','Context-sensitive help',...
    'CData',s.whatsthis,'Tag','Help');

% Disable toolbar at start (except help if doc installed)
set([b,z,h],'HandleVisibility','off','Enable','off')
if ~isempty(docroot)
    set(h,'Enable','on')
end

% Default mode
BZH = [b,z,h];
set(a,'ClickedCallback',{@LocalResetMode a BZH sisodb}); 

% Add and delete callbacks
set(b(1),'OnCallback',{@LocalEnterMode sisodb 'addpz' ...
        struct('Root','Pole','Group','Real') BZH a})
set(b(2),'OnCallback',{@LocalEnterMode sisodb 'addpz' ...
        struct('Root','Zero','Group','Real') BZH a})
set(b(3),'OnCallback',{@LocalEnterMode sisodb 'addpz' ...
        struct('Root','Pole','Group','Complex') BZH a})
set(b(4),'OnCallback',{@LocalEnterMode sisodb 'addpz' ...
        struct('Root','Zero','Group','Complex') BZH a})
set(b(5),'OnCallback',{@LocalEnterMode sisodb 'deletepz' [] BZH a})

% Zoom and pan callbacks
set(z(1),'OnCallback',{@LocalEnterMode sisodb 'zoom' ...
        'in' BZH a})
set(z(2),'OnCallback',{@LocalEnterMode sisodb 'zoom' ...
        'out' BZH a})
set(z(3),'OnCallback',{@LocalEnterMode sisodb 'pan' ...
        'on' BZH a})

% Off callbacks
set([b,z],'OffCallback',{@LocalExitMode sisodb})

% Help callbacks
set(h,'OnCallback',{@LocalEnterMode sisodb 'help' [] BZH a},...
    'OffCallback',{@LocalExitHelp sisodb a})

% Listen to changes in editor mode 
lsnr = handle.listener(sisodb,sisodb.findprop('GlobalMode'),...
    'PropertyPostSet',{@LocalSetMode a BZH sisodb});
set(a,'UserData',lsnr);

% output
ToggleHandles = [a , BZH];



%----------------------------- Callback actions ----------------------------
   
%%%%%%%%%%%%%%%%%%%%%%
%%% LocalEnterMode %%%
%%%%%%%%%%%%%%%%%%%%%%
function LocalEnterMode(hSrc,event,sisodb,NewMode,ModeData,hToggle,hArrow)
% Callback when engaging global edit mode

% Disable listener on GlobalMode (otherwise GlobalMode=off unselects toolbar button!)
GlobalModeListener = get(hArrow,'UserData');
GlobalModeListener.Enabled = 'off';

% Abort current global mode and revert to idle mode locally
% RE: Makes sure Add/Zoom submenus get correctly set (listener
%     may not be triggered if new global mode = current editor mode)
sisodb.GlobalMode = 'off';
if ~isoff(sisodb)  
    % RE: Don't go to idle if no data has been loaded yet (for cs help)
    set(sisodb.PlotEditors,'EditMode','idle');
end

% Set the button states
set(hToggle(hToggle~=hSrc),'State','off')   % no side effect (GlobalMode already off)
set(hArrow,'State','off')    % turning a button off turns the arrow back on...

% Enter new mode and notify editors of change of mode/scope
if ~any(strcmp(NewMode,{'zoom','pan'}))
    % Turn off pan and zoom
    pan(sisodb.Figure,'off')
    zoom(sisodb.Figure,'off')
    if strcmp(NewMode,'help')
        % Make sure can't open Import (can interfer badly with CS help by changing plots)
        set(sisodb.HG.Menus.File.Import,'enable','off')
        sisodb.Figure.CSHelpMode = 'on';
    else
        set(sisodb.PlotEditors,'EditModeData',ModeData,'EditMode',NewMode);
    end
end

% Restore listener
sisodb.GlobalMode = 'on';
GlobalModeListener.Enabled = 'on';


%%%%%%%%%%%%%%%%%%%%%
%%% LocalExitMode %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalExitMode(hSrc,event,sisodb)
% Callback when unselecting mode (button state to off)
sisodb.GlobalMode = 'off';


%%%%%%%%%%%%%%%%%%%%%
%%% LocalExitHelp %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalExitHelp(hSrc,event,sisodb,hArrow)
% Exit CS help mode
sisodb.Figure.CSHelpMode = 'off';
set(sisodb.HG.Menus.File.Import,'enable','on')
sisodb.GlobalMode = 'off';


%%%%%%%%%%%%%%%%%%%%%%
%%% LocalResetMode %%%
%%%%%%%%%%%%%%%%%%%%%%
function LocalResetMode(hProp,event,hArrow,hToggle,sisodb)
% Triggered when pressing arrow
set(hToggle,'State','off')
% Turn off pan and zoom
pan(sisodb.Figure,'off')
zoom(sisodb.Figure,'off')
% Always turn arrow back on when pressed (otherwise press+press may leave all 
% buttons depressed)
set(hArrow,'State','on')


%%%%%%%%%%%%%%%%%%%%
%%% LocalSetMode %%%
%%%%%%%%%%%%%%%%%%%%
function LocalSetMode(hProp,event,hArrow,hToggle,sisodb)
% PostSet callback for GlobalMode property. Triggered when pressing toolbar button, 
% changing edit mode locally, or through ESC
if strcmp(event.NewValue,'off')  % GlobalMode set to off
    % Turn all buttons off and arrow back on 
    % RE: Separate listener sets local modes to idle
    % Turn off pan and zoom
    pan(sisodb.Figure,'off')
    zoom(sisodb.Figure,'off')
    set(hToggle,'State','off')
    set(hArrow,'State','on')
end
