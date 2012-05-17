function draw(this,fig)

% Copyright 2008 The MathWorks, Inc.

% Draws brushing annotations

h = this.HGHandle;
if nargin==1
    fig = ancestor(h,'figure');
end
selectionHandles = this.SelectionHandles;
zdata = get(h,'zdata');
ydata = get(h,'ydata');
xdata = get(h,'xdata');

% Find the brush color
I = this.HGHandle.BrushData;
brushColor = zeros(size(I,1),3);
brushStyleMap = get(fig,'BrushStyleMap');
for row=1:size(I,1)
    ind = find(I(row,:)>0);
    if ~isempty(ind)
        brushColor(row,:) = brushStyleMap(rem(I(row,ind(1))-1,size(brushStyleMap,1))+1,:);
    end
end

% If necessary, build selection markers and create update listeners
hMarkerSize = sqrt(max(get(h,'SizeData')));
sizeIncrement = min(sqrt(max(get(h,'SizeData'))),5);
newBrushingGraphics = (size(I,1)>length(selectionHandles));
for row=length(selectionHandles)+1:size(I,1)
    % We must use a patch rather than another scatter group because the 
    % scattergroup refresh method is too inefficient (repeated destruction
    % and construction of patches)
    selectionHandles(row) = line('Parent',get(h,'Parent'),...
        'LineStyle','none','Marker',get(h,'Marker'),...
        'MarkerSize',hMarkerSize+sizeIncrement*(size(I,1)-row),...
        'MarkerEdgeColor',brushColor(row,:),...
        'MarkerFaceColor',brushColor(row,:),...
        'ButtonDownFcn',{@datamanager.drag this},...
        'Tag','Brushing',...
        'HandleVisibility','off',...
        'IncludeRenderer','off',...
        'xliminclude','off','yliminclude','off','zliminclude','off');    
end
if newBrushingGraphics
   this.SelectionHandles = selectionHandles;
   this.addContextMenu;
   this.addBehaviorObjects;
end

for row=size(I,1)+1:length(selectionHandles)
    set(selectionHandles(row),'Visible','off'); 
end

% Clear brushing if the sizes became incompatible
if ~isempty(I) && (size(I,2)~=length(ydata) || size(I,2)~=length(xdata)) 
    this.HGHandle.BrushData = [];
    set(selectionHandles,'visible','off');
    return;
end

% Draw the brushing annotations
if isempty(xdata) || ~isequal(size(ydata),size(xdata))
    set(selectionHandles,'visible','off');
    return;
elseif ~isempty(I)
    hvis = get(h,'Visible');
    hMarker = get(h,'Marker');
    for row=1:size(I,1)
       brushzdata = zdata;
       brushydata = ydata;
       brushxdata = xdata;
       brushydata(I(row,:)==0) = NaN;
       brushxdata(I(row,:)==0) = NaN;
       if ~isempty(brushzdata)
            brushzdata(I(row,:)==0) = NaN;
            set(selectionHandles(row),'XData',brushxdata,...
               'Ydata',brushydata,...
               'ZData',brushzdata,...          
               'Marker',hMarker,...
               'MarkerSize',hMarkerSize+sizeIncrement*(size(I,1)-row),...
               'MarkerEdgeColor',brushColor(row,:),...
               'MarkerFaceColor',brushColor(row,:),...
               'Visible',hvis);   
       else
            set(selectionHandles(row),'XData',brushxdata,...
               'YData',brushydata,...
               'Marker',hMarker,...
               'MarkerSize',hMarkerSize+sizeIncrement*(size(I,1)-row),...
               'MarkerEdgeColor',brushColor(row,:),...
               'Visible',hvis,...
               'MarkerFaceColor',brushColor(row,:)); 
       end
  
    end
end
