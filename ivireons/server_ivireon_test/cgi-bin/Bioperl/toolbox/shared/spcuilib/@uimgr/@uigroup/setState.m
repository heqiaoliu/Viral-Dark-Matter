function setState(h,idx,val)
%SETSTATE Set the state of the item to val
%   SETSTATE(ARGS) 
% Turn on the specified widget within the specified group.
%   setState(h,idx) turns on the idx'th child widget in the group.
%   idx must be in range [1...N], where N is the number of widgets in the 
%   group, otherwise the action is ignored.
%   setState(h,idx,val) specifies the value to use for turning on the
%   idx'th widget.  If omitted, 'on' is used as the value.
%
%   Note, for the buttons you must use the oncallback widget properties to
%   make the buttons callback fire upon using setState.
%
%   % Example 1:
%     icons = load('audiotoolbaricons');
%   
%     bPlay = uimgr.spctoggletool('Play');
%     bPlay.WidgetProperties = {'oncallback', 'disp(''play button clicked'')'...
%                              'offcallback', 'disp(''pause button clicked'')'};
%     bPlay.IconAppData = {'pause_default','play_on'};
% 
%     bStop = uimgr.spcpushtool('Stop');
%     bStop.IconAppData = {'stop_default'};
%   
%     bRecord = uimgr.spctoggletool('Record');
%     bRecord.WidgetProperties = {'oncallback', 'disp(''record off button clicked'')'...
%                               'offcallback', 'disp(''record off button clicked'')'};
%     bRecord.IconAppData = {'record_off','record_on'};
% 
%     playGroup = uimgr.uibuttongroup('playGroup', bPlay, bStop, bRecord);
% 
%     tbPlay = uimgr.uitoolbar('Toolbar',playGroup);
% 
%     hFig = uimgr.uifigure('myfig', tbPlay);
%     hFig.setappdata(icons);
%     hFig.render;
%   
%    %now get the child to set its state
%     hPlayPostRender = hFig.findchild('myfig/Toolbar/playGroup');
%     hPlayPostRender.setState(3);
%
%    %now set the state of the item to 'off'
%     hPlayPostRender.setState(3, 'off');

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2009/12/11 21:11:38 $

if (idx >= 1) && (idx <= h.getNumChildren)
    h = h.down; % get first child
    for i = 1:idx-1
        h = h.right;
    end
    hWidget = h.hWidget;
    if nargin<3
        val='on';
    end
    if ~isempty(hWidget)
        set(hWidget,h.StateName,val);
    end
end


% [EOF]
