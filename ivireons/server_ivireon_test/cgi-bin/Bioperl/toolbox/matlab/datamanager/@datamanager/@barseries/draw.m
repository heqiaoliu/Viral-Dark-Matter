function draw(this,fig)

% Draws brushing annotations

h = this.HGHandle;
if nargin==1
    fig = ancestor(h,'figure');
end
ydata = get(h,'ydata');
xdata = get(h,'xdata');
ydata = ydata(:);
xdata = xdata(:);

% Find the brush color
I = this.HGHandle.BrushData;
brushColor = zeros(size(I,1),3);
brushStyleMap = get(fig,'BrushStyleMap');
ind = find(I>0);
if ~isempty(ind)
    brushColor = brushStyleMap(rem(I(ind(1))-1,size(brushStyleMap,1))+1,:);
    if ~isempty(this.SelectionHandles)
        set(this.SelectionHandles,'FaceColor',brushColor,'EdgeColor',brushColor);
    end
end

% If necessary, build selection markers and create update listeners
if isempty(this.SelectionHandles) && size(I,1)>=1
    peerObj = get(this.HGHandle,'BarPeers');
    for k=length(peerObj):-1:1   
       brushPeers(k) = localAddBrushAnnotation(getappdata(double(peerObj(k)),...
           'Brushing__'),brushColor); %#ok<AGROW>
    end 
    for k=1:length(brushPeers)
        set(brushPeers(k),'BarPeers',brushPeers);
    end
end
for row=size(I,1)+1:length(this.SelectionHandles)
    set(this.SelectionHandles(row),'Visible','off');
end


% Clear brushing if the sizes became incompatible
if ~isempty(I) && (size(I,2)~=length(ydata) || size(I,2)~=length(xdata))
    this.HGHandle.BrushData = [];
    set(this.SelectionHandles,'visible','off');
    return;
end

% Draw the brushing annotations
if isempty(xdata) || ~isequal(size(ydata),size(xdata))
    set(this.SelectionHandles,'visible','off');
    return;
elseif ~isempty(I)
   brushydata = ydata;
   brushxdata = xdata;
   baseVal = get(h,'BaseValue');
   brushydata(~I(1,:)) = baseVal;
   % Clear linestyle if there is no brushing so that a crufty red line does
   % not get left at the base after clearing brushing g419124.
   if any(I(1,:))
       lineStyle = get(h,'LineStyle');
   else
       lineStyle = 'none';
   end
   peers = get(this.HGHandle,'BarPeers');
   for j=length(peers):-1:1
       peerH = getappdata(double(peers(j)),'Brushing__');
       barpeers(j) = peerH.SelectionHandles; %#ok<AGROW>
   end
   set(this.SelectionHandles,'xdata',brushxdata,'ydata',brushydata,...
        'visible',get(h,'Visible'),'Barwidth',get(h,'BarWidth'),'BarLayout',...
        get(h,'BarLayout'),'BarPeers',barpeers,'LineStyle',lineStyle);
   refresh(handle(this.SelectionHandles))
end


function selectionHandles = localAddBrushAnnotation(this,brushColor)

if ~isempty(this.SelectionHandles) && ishghandle(this.SelectionHandles)
    selectionHandles = this.SelectionHandles;
    return
end
selectionHandles =  specgraph.barseries('Parent',get(this.HGHandle,'Parent'),...
    'HandleVis','off','Tag','Brushing','LineStyle',get(this.HGHandle,'LineStyle'),...
    'ButtonDownFcn',{@datamanager.drag this},'Horizontal',get(this.HGHandle,'Horizontal'),...
    'ShowBaseLine','off','Serializable','off','xliminclude','off',...
    'yliminclude','off','zliminclude','off','Horizontal',get(this.HGHandle,'Horizontal'),...
    'BarLayout',get(this.HGHandle,'BarLayout'),'BarWidth',get(this.HGHandle,'BarWidth'));
set(selectionHandles,'Edgecolor',brushColor,'Facecolor',brushColor);
this.SelectionHandles = selectionHandles;

% Create context menu
this.addContextMenu;

% Customize brushing graphic behavior
this.addBehaviorObjects;