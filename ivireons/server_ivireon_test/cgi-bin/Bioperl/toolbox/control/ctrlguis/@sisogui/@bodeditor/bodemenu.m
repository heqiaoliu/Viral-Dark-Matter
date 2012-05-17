function h = bodemenu(Editor,Anchor,MenuType)
%BODEMENU  Creates menus specific to the Bode editor.
% 
%   H = BODEMENU(EDITOR,ANCHOR,MENUTYPE) creates a menu item, related
%   submenus, and associated listeners.  The menu is attached to the 
%   parent object with handle ANCHOR.

%   Author(s): P. Gahinet, N. Hickey
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.17.4.2 $ $Date: 2005/12/22 17:42:02 $

switch MenuType
   
   case 'magphase'
      % Mag and phase submenus
      h1 = uimenu(Anchor,'Label',sprintf('Magnitude'), ...
         'Checked',Editor.MagVisible);
      h2 = uimenu(Anchor,'Label',sprintf('Phase'), ...
         'Checked',Editor.PhaseVisible);
      h = [h1;h2];
      set(h,'Callback',{@LocalShowMagPhase Editor h})
      
      lsnr = [handle.listener(Editor,findprop(Editor,'MagVisible'),...
            'PropertyPostSet',{@LocalSetCheck h1}) ; ...
            handle.listener(Editor,findprop(Editor,'PhaseVisible'),...
            'PropertyPostSet',{@LocalSetCheck h2})];
      set(h1,'UserData',lsnr)  % Anchor listeners for persistency
      
end

%----------------------------- Listener callbacks ----------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalShowMagPhase %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalShowMagPhase(hSrc,event,Editor,hMagPhase)
% Callbacks for Mag/Phase submenus

idxSrc = find(hSrc==hMagPhase);

% Determine new states of mag/phase menus
isOn = strcmp(get(hMagPhase,'Checked'),'on');
isOn(idxSrc) = ~isOn(idxSrc);

if ~any(isOn)
    % Both deselected: abort toggle operation
    Status = sprintf('At least one of the magnitude or phase plots must be displayed.');
else
    % Set corresponding mode
    States = {'off','on'};
    if idxSrc==1
        Editor.MagVisible = States{1+isOn(1)};
    else
        Editor.PhaseVisible = States{1+isOn(2)};
    end
    Plots = {'magnitude','phase'};
    Status = {'hidden','visible'};
    Status = sprintf('The %s plot is now %s.',sprintf(Plots{idxSrc}),sprintf(Status{1+isOn(idxSrc)}));
end

% Make status persistent but don't record it
Editor.EventManager.newstatus(Status);
Editor.EventManager.recordtxt('history',Status);


%%%%%%%%%%%%%%%%%%%%%
%%% LocalSetCheck %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalSetCheck(hProp,event,hMenu)
% Callbacks for property listeners
set(hMenu,'Checked',event.NewValue);
