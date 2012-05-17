function h = ipthittest(hFigure, currentPoint)
%IPTHITTEST
%   This is an undocumented function and may be removed in a future release.

%IPTHITTEST Handle of object currently under the mouse pointer.
%   handle = ipthittest(hFigure, currentPoint) returns the handle of the HG
%   object under the mouse pointer at a specific location.
%
%   See also iptGetPointerBehavior, iptPointerManager, iptSetPointerBehavior.

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/02/06 14:27:31 $

% Preconditions (not checked):
%     Two input arguments
%     First input argument is a valid HG figure handle
%     Second input argument is a valid figure CurrentPoint
%
%     Design note: It is a deliberate design choice for this routine not to
%     validate its input arguments.  ipthittest will be called for every
%     WindowButtonMotionEvent and needs to run as quickly as possible.

% Information hiding:
%     This routine hides knowledge of hittest bugs and their associated
%     work-arounds from the rest of the pointer management code.

% Initialize the table of functions that work around specific hittest
% problems.
workaroundTable = {@fixImScrollbars};

% Initialize output handle by calling the undocumented builtin hittest function.

h = hittest(hFigure, currentPoint);
if isempty(h)
    return;
end

% Invoke each function in the work-around table.
for k = 1:numel(workaroundTable)
    fcn = workaroundTable{k};
    h = fcn(h, hFigure, currentPoint);
end

%----------------------------------------------------------------------
function hnew = fixImScrollbars(h, hFigure, currentPoint)  %#ok - hFigure unused

hnew = h;

hPanel = imshared.getimscrollpanel(h);
isImageInsideScrollpanel = ~isempty(hPanel);

if ~isImageInsideScrollpanel
    return;
end

if ~isOverScrollbars(currentPoint(1), currentPoint(2), hPanel)
    return;
end

hSliders = findobj(hPanel, 'Type', 'uicontrol', ...
                   'Style', 'slider');

% For ipthittest purposes, it is necessary only to return one of the
% sliders; it is not necessary to take the extra step of determining which
% one.  If it should become necessary to return that information, then modify
% isOverScrollbars to return the information as an additional output
% argument, since isOverScrollbars is already doing that computation.

hnew = hSliders(1);

%----------------------------------------------------------------------
function over_scrollbars = isOverScrollbars(cpx,cpy,hScrollpanel)
%isOverScrollbars Returns true if over the scrollbars.
%   OVER = isOverScrollbars(X,Y,H_SCROLLPANEL) calculates whether coordinate
%   (X,Y) falls inside the scrollbars or corner frame of the scroll panel
%   H_SCROLLPANEL. 

% Temporarily disable ResizeFcn to avoid recursion
actualResizeFcn = get(hScrollpanel,'ResizeFcn');
set(hScrollpanel,'ResizeFcn','')

hSliders = findobj(hScrollpanel,'Type','Uicontrol','Style','slider');
isVisible = @(h) strcmp( get(h,'Visible'), 'on');

% Defining logical variable to pass to getpixelposition.  We want to call
% getpixelposition recursively so that mouse position and slider/frame
% positions are compared relative to figure.
isRecursive = true;

slider1_pos = getpixelposition(hSliders(1),isRecursive);
over_slider1 = isVisible(hSliders(1)) && isOver(cpx,cpy,slider1_pos);

slider2_pos = getpixelposition(hSliders(2),isRecursive);
over_slider2 = isVisible(hSliders(2)) && isOver(cpx,cpy,slider2_pos);

hFrame = findobj(hScrollpanel,'Type','Uicontrol','Style','frame');
frame_pos = getpixelposition(hFrame,isRecursive);
over_frame = isVisible(hFrame) && isOver(cpx,cpy,frame_pos);
    
over_scrollbars = over_slider1 || over_slider2 || over_frame;

% Restore ResizeFcn
set(hScrollpanel,'ResizeFcn',actualResizeFcn)
  
%----------------------------------------------------------------------
function over = isOver(x,y,pos)
%isOver Returns true if the coordinates fall within the object position.
%   OVER = isOver(X,Y,POS) calculates whether coordinate (X,Y) falls
%   inside the position rectangle defined by POS where POS = [XMIN YMIN
%   WIDTH HEIGHT].

xmin = pos(1);
xmax = pos(1) + pos(3);
ymin = pos(2);
ymax = pos(2) + pos(4);

if (x >= xmin) && (x <= xmax) && ...
         (y >= ymin) && (y <= ymax)
    over = true;
else
    over = false;
end
  
