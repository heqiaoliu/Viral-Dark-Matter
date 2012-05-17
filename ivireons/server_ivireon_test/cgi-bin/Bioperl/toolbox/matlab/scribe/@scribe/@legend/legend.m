function h=legend(varargin)
%LEGEND creates the scribe legend object
%  H=SCRIBE.LEGEND creates a scribe legend instance
%
%  See also PLOTEDIT

%   Copyright 1984-2007 The MathWorks, Inc.

if (nargin == 0) || ischar(varargin{1})
  hasConvenienceArgs = false;
  parind = find(strcmpi(varargin,'parent'));
  if isempty(parind)
    fig = gcf;
  else
      par = varargin{parind(end)+1};
      fig = ancestor(varargin{parind(end)+1},'figure');
  end
  if ~isappdata(0,'BusyDeserializing')
      ax = get(fig,'CurrentAxes');
      if isempty(ax)
          ax = axes('parent',fig);
      end
      position = [];
      children = [];
      par = get(ax,'Parent');
  end
else
  hasConvenienceArgs = true;
  ax=varargin{1};
  fig = ancestor(ax,'figure');
  orient=varargin{2};
  location=varargin{3};
  position=varargin{4};
  children=varargin{5};
  listen=varargin{6};
  strings=varargin{7};
  varargin(1:7) = [];
  par = get(ax,'Parent');
end
% be sure nextplot is 'add'
oldNextPlot = get(fig,'NextPlot');
if strcmp(oldNextPlot,'replacechildren') || strcmp(oldNextPlot,'replace')
    set(fig,'NextPlot','add');
end
% start not visible so resizing etc. can't be seen.
h = scribe.legend('Parent',par,'Tag','legend','Visible','off', ...
                  'Units','normalized','Interruptible','off', ...
                  'LooseInset',[0 0 0 0]);
set(h,'EdgeColor',get(par,'DefaultAxesXColor'));
set(h,'TextColor',get(par,'DefaultTextColor'));
b = hggetbehavior(double(h),'Pan');
set(b,'Enable',false);
b = hggetbehavior(double(h),'Zoom');
set(b,'Enable',false);
b = hggetbehavior(double(h),'Rotate3D');
set(b,'Enable',false);
b = hggetbehavior(double(h),'DataCursor');
set(b,'Enable',false);
b = hggetbehavior(double(h),'Plotedit');
set(b,'KeepContextMenu',true);
set(b,'AllowInteriorMove',true);
set(b,'ButtonUpFcn',methods(h,'getfunhan','-noobj','ploteditbup'));
set(b,'EnableCopy',false);

if ~isappdata(0,'BusyDeserializing')

  if hasConvenienceArgs
    % set legendinfochildren on if children are legendinfo objects
    if isa(children(1),'scribe.legendinfo')
      h.LegendInfoChildren = 'on';
    end
    h.Plotchildren = children;
    if listen
      h.PlotChildListen = 'on';
    else
      h.PlotChildListen = 'off';
    end
    h.Orientation = orient;
    h.Location = location;
    h.String = strings;
  end
  h.Axes = ax;
  % font properties from axes
  h.FontName = get(ax,'fontname');
  h.FontAngle = get(ax,'fontangle');
  h.FontSize = get(ax,'fontsize');
  h.FontWeight = get(ax,'fontweight');
  h.Units = 'normalized';
  h.Selected = 'off';
  if strcmp(get(ax,'color'),'none')
    h.Color = get(fig,'color');
  else
    h.Color = get(ax,'color');
  end
  
  set(double(h),...
      'Units','normalized',...
      'Box','on',...
      'DrawMode', 'fast',...
      'NextPlot','add',...
      'XTick',-1,...
      'YTick',-1,...
      'XTickLabel','',...
      'YTickLabel','',...
      'XLim',[0 1],...
      'YLim',[0 1], ...
      'Clipping','on',...
      'Color',h.Color,...
      'View',[0 90],...
      'CLim',get(ax,'CLim'));
  set(h,'Units',get(ax,'Units'));
  
  set(fig,'NextPlot',oldNextPlot);
  if ~isempty(children)
    methods(h,'create_legend_items',children);
  end  

  set(double(h),'visible','on');
  set(fig,'currentaxes',ax);
  
  %%Initialize the listeners
  h.init(); 
    
  % set other properties passed in varargin
  set(h,varargin{:});      
  
  % Set the positin manually, if specified
  if ~isempty(position) && length(position)==4
      units = get(double(h), 'units');
      set(double(h), 'units', 'normalized');      
      set(double(h),'Position',position);
      set(double(h), 'units', units);
  end

  % SET USER DATA
  % Note: The 'update_userdata' method MUST be called only after all the
  % listeners are initialized.
  methods(h,'update_userdata');
  
  % Add appdata to the axes that points back to the legend. This appdata
  % will be used to speed up the execution time of the h = legend(ax)
  % syntax.
  setappdata(double(ax),'LegendPeerHandle',double(h));
  
  % set legend ready (complete) on.
  h.Ready = 'on';

end
% now make visible
set(h,'Visible','on');
