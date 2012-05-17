function setState(theItem,val)
%SETSTATE Set the state of the specified widget
%   SETSTATE(ARGS) setState(H,VAL) sets the state of the widget H to VAL.
%
%   Note, for the buttons you must use the oncallback widget properties to
%   make the buttons callback fire upon using setState.
%
%   % Example 1:
%     icons = load('audiotoolbaricons');
%   
%     bPlay = uimgr.spctoggletool('Play');
%     bPlay.WidgetProperties = {'oncallback', 'disp(''pause button clicked'')'...
%                              'offcallback', 'disp(''play button clicked'')'};
%     bPlay.IconAppData = {'play_on','pause_default'};
%     tbPlay = uimgr.uitoolbar('Toolbar', bPlay);
% 
%     hFig = uimgr.uifigure('myfig', tbPlay);
%     hFig.setappdata(icons);
%     hFig.render;
%   
%   %now get the child to set its state
%     hPlayPostRender = hFig.findchild('myfig/Toolbar/Play');
%     hPlayPostRender.setState('on');
%
%   %now set the state of the item to 'off'
%     hPlayPostRender.setState('off');

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/12/11 21:11:39 $

hWidget = theItem.hWidget;
set(hWidget,theItem.StateName,val);

% [EOF]
