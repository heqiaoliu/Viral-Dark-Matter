function linkaxes(ax,option)
%LINKAXES Synchronize limits of specified 2-D axes
%  Use LINKAXES to synchronize the individual axis limits
%  on different subplots within a figure. Calling linkaxes
%  will make all input axis have identical limits. This is useful
%  when you want to zoom or pan in one subplot and display 
%  the same range of data in another subplot.
%
%  LINKAXES(AX) Links x and y-axis limits of the 2-D axes 
%  specified in AX.
%
%  LINKAXES(AX,OPTION) Links the axes AX according to the 
%  specified option. The option argument can be one of the 
%  following strings: 
%        'x'   ...link x-axis only
%        'y'   ...link y-axis only
%        'xy'  ...link x-axis and y-axis
%        'off' ...remove linking
%
%  See the LINKPROP function for more advanced capabilities 
%  that allows linking object properties on any graphics object.
%
%  Example (Linked Zoom & Pan):
%
%  ax(1) = subplot(2,2,1);
%  plot(rand(1,10)*10,'Parent',ax(1));
%  ax(2) = subplot(2,2,2);
%  plot(rand(1,10)*100,'Parent',ax(2));
%  linkaxes(ax,'x');
%  % Interactively zoom and pan to see link effect
%
%  See also LINKPROP, ZOOM, PAN.

% Copyright 2003-2009 The MathWorks, Inc.

if nargin==0
    fig = get(0,'CurrentFigure');
    if isempty(fig), return; end
    ax = findobj(fig,'Type','Axes');
    nondatachild = logical([]);
    for k=length(ax):-1:1
      nondatachild(k) = isappdata(ax(k),'NonDataObject');
    end
    ax(nondatachild) = [];
    option = 'xy';
    
elseif nargin==1
    option = 'xy';
end

h = handle(ax);
if isempty(h) || ~all(ishghandle(h,'axes'))
    error('MATLAB:linkaxes:InvalidFirstArgument', 'First input argument must be axes handles.');
end

% Only support 2-D axes
if ~all(local_is2D(h))
    warning('MATLAB:linkaxes:Requires2Dinput',...
            'linkaxes requires 2-D axes as input. Use linkprop for generic property linking.');
end

% Remove any prior links to input handles
localRemoveLink(ax)

% Flush graphics queue so that all axes
% are forced to update their limits. Otherwise,
% calling XLimMode below may get the wrong axis limits
drawnow;

% Create new link
switch option
    case 'x'
        set(ax,'XLimMode','manual');
        hlink = linkprop(ax,'XLim');
    case 'y'
        set(ax,'YLimMode','manual');
        hlink = linkprop(ax,'YLim');
    case 'xy'
        set(ax,'XLimMode','manual','YLimMode','manual');
        hlink = linkprop(ax,{'XLim','YLim'});
    case 'off'
        hlink = [];
    otherwise
     error('MATLAB:linkaxes:InvalidSecondArgument',...
         'Second input argument must be one of ''x'', ''y'', ''xy'', or ''off''.');
end

KEY = 'graphics_linkaxes';
for i=1:length(ax)
    setappdata(ax(i),KEY,hlink);
end

%--------------------------------------------------%
function localRemoveLink(ax)

KEY = 'graphics_linkaxes';

for n = 1:length(ax)
  % Remove this handle from previous link object
  hlink = getappdata(ax(n),KEY);
  if any(ishandle(hlink))
      removetarget(hlink,ax(n));
  end
end

% Deletion of link object will occur implicitly 
% when no more handles reference the link object

%--------------------------------------------------%
function [bool] = local_is2D(ax)
% Don't call is2D.m for now since that only considers x-y plots
bool = false(1,length(ax));
for n = 1:length(ax)
  bool(n) = logical(sum(campos(ax(n))-camtarget(ax(n))==0)==2);
end
