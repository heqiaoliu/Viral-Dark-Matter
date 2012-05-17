function linkMenu(this,MenuIndex,View,idx)
%LINKMENU  Links Analysis menu to particular View.

%   Author(s): P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2008/12/29 01:47:17 $

% Loacate menu
hMenu = this.Parent.HG.Menus.Analysis.PlotSelection(MenuIndex); 

% Update menu's tracking info
L1 = handle.listener(View,View.findprop('Visible'),'PropertyPostSet',@(x,y) LocalUncheck(hMenu));
L2 = addlistener(this.Figure,'Visible','PostSet',@(x,y) LocalFigVis(hMenu,this));
set(hMenu,'UserData',struct('View',View,'Listener',struct('L1',L1,'L2',L2)));

%%%%%%%%%%%%%%%%%%%%
%%% LocalUncheck %%%
%%%%%%%%%%%%%%%%%%%%
function LocalUncheck(hMenu)

% Uncheck plot menu when associated view goes invisible
set(hMenu,'Checked','off')
UD = get(hMenu,'UserData');
if isfield(UD,'Listener')
   delete(UD.Listener.L1);
   delete(UD.Listener.L2);
end
set(hMenu,'UserData',[]);


%%%%%%%%%%%%%%%%%%%%
%%% LocalFigVis  %%%
%%%%%%%%%%%%%%%%%%%%
function LocalFigVis(hMenu,this)

if strcmpi(this.Figure.Visible,'off')
    LocalUncheck(hMenu)
end