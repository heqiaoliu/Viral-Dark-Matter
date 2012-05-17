function initialize(this, ax, gridsize)
%  INITIALIZE  Initializes the @hsvplot objects.

%  Author(s): P. Gahinet
%  Copyright 1986-2009 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:21:03 $

% Create @axes object
% RE: Title, etc initialized in HSVPlotOptions
Axes = ctrluis.axes(ax, ...
   'Visible',     'off', ...
   'LimitFcn',    {@updatelims this},...
   'XScale',      'Linear');

this.AxesGrid = Axes;

% Generic initialization
init_graphics(this)

% Add standard listeners
addlisteners(this)

% Other listeners
AxStyle = Axes.AxesStyle;
L = [handle.listener(Axes,'PreLimitChanged',@(x,y) LocalAdjustView(this)) ; ...
   handle.listener(this,this.findprop('Options'),'PropertyPostSet',...
   @(x,y) localUpdate(this))];
this.addlisteners(L);

%-------------------------- Local Functions ----------------------------

function LocalAdjustView(this)
% Prepares view for limit picker
if ~isempty(this.Responses)
   adjustview(this.Responses,'prelim')
end

function localUpdate(this)
% Recomputes HSV when numerical options change
r = this.Responses;
if ~isempty(r)
   % Clear data
   clear(r.Data)
   % Redraw (forces DataFcn evaluation)
   draw(r)
   % workaround: Update legend (see g245058)
   ax = double(getaxes(this.AxesGrid));
   if ~isempty(legend(ax))
      legend(ax,'off')
      legend(ax,'show')
   end
   % end workaround
end