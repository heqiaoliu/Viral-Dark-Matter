function draw(this,fig)


% Draws brushing annotations

h = this.HGHandle;
selectionHandles = this.SelectionHandles;
if nargin==1
    fig = ancestor(h,'figure');
end
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
newBrushingGraphics = (size(I,1)>length(selectionHandles));
for row=length(selectionHandles)+1:size(I,1)
    %lineseriesmex;
    
    selectionHandles(row) = line('Parent',get(h,'Parent'),...
        'color',brushColor(row,:),'linewidth',h.LineWidth+2*row,'marker','x',...
        'HandleVis','off','Tag','Brushing','Serializable','off',...
        'ButtonDownFcn',{@datamanager.drag this},'xliminclude','off','yliminclude','off',...
         'zliminclude','off');
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
    hLineStyle = get(h,'LineStyle');
    for row=1:size(I,1)
       brushzdata = zdata;
       brushydata = ydata;
       brushxdata = xdata;
       brushydata(I(row,:)==0) = NaN;
       brushxdata(I(row,:)==0) = NaN;
       if ~isempty(brushzdata)
            brushzdata(I(row,:)==0) = NaN;
       end
       locBrushColor = brushColor(row,:);
       set(selectionHandles(row),'xdata',brushxdata,'ydata',brushydata,...
            'zdata',brushzdata,'LineStyle',hLineStyle,'Color',locBrushColor,...
            'MarkerFaceColor',locBrushColor,'MarkerEdgeColor',locBrushColor,...
            'visible',hvis);
    end
end