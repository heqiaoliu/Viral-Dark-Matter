function m = addCharMenu(hplot, CharMenuHandle, CharID, dataClass, viewClass, inputviewClass)
%ADDCHARMENU   Adds menus for @simplot characteristics.

%  Author(s): James Owen, P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:24:40 $

% Extends generic implementation in @wrfc/@plot
if nargin<6,
   inputviewClass = '';
end

% Create submenu for specified characteristic if it does not already exist
subMenus=get(CharMenuHandle,'Children');
m = subMenus(strcmpi(CharID,get(subMenus,'Label')));
if isempty(m)
   m = uimenu('Parent',CharMenuHandle,'Label',CharID,...
      'Callback',@(x,y) localCallback(x,hplot,CharID,dataClass,viewClass,inputviewClass),...
      'UserData',{CharID,dataClass,viewClass});
end


%-------------------- Local Functions --------------------------

function localCallback(eventSrc,hplot,Identifier,dataClass,viewClass,inputviewClass)
% Toggles characteristic visibility based on checked state of menu
m=eventSrc;  %menu handle
if strcmp(get(m,'checked'),'on');
   newState='off';
else
   newState='on';
end

% Update menu check
set(m,'checked',newState);

% Add characteristic to waveform's that don't already have it, and set its global visibility
hplot.addchar(Identifier,dataClass,viewClass,inputviewClass,'Visible',newState)
