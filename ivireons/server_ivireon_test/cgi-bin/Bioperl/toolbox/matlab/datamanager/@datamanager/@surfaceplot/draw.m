function draw(this,fig)

% Draws brushing annoations

h = this.HGHandle;
if nargin==1
    fig = ancestor(h,'figure');
end

% We must use openGL
set(fig,'Renderer','openGL','RendererMode','manual');

selectionHandles = this.SelectionHandles;
fig = ancestor(h,'figure');
zdata = get(h,'zdata');
ydata = get(h,'ydata');
xdata = get(h,'xdata');

% Find the brush color
I = this.HGHandle.BrushData;
brushColor = zeros(size(I,3),3);
brushStyleMap = get(fig,'BrushStyleMap');
for row=1:size(I,3)
    ind = find(I(:,:,row)>0);
    if ~isempty(ind)
        brushColor(row,:) = brushStyleMap(rem(I(ind(1))-1,size(brushStyleMap,1))+1,:);
    end
end

% If necessary, build selection markers and create update listeners
newBrushingGraphics = (size(I,1)>length(selectionHandles));
for row=length(selectionHandles)+1:size(I,3)
    %lineseriesmex;
    
    % TO DO: Add a brushing annoation just behind the corresponding line
    selectionHandles(row) = graph3d.surfaceplot('Parent',get(h,'Parent'),...
        'FaceColor',brushColor(row,:),'linewidth',h.LineWidth+2*row,'marker','x',...
        'HandleVis','callback','Tag','Brushing','Serializable','off',...
        'ButtonDownFcn',{@datamanager.drag this},'xliminclude','off',...
        'Facecolor','w','MarkerEdgeColor','w','xdata',[],'ydata',[],'zdata',[],...    
        'yliminclude','off','zliminclude','off');
end
if newBrushingGraphics
   this.SelectionHandles = selectionHandles;
   this.addContextMenu;
   this.addBehaviorObjects;   
end

for row=size(I,3)+1:length(selectionHandles)
    set(selectionHandles(row),'Visible','off');
end

% Clear brushing if the sizes became incompatible
if ~isempty(I) && ~isequal(size(I),size(zdata))
    this.HGHandle.BrushData = [];
    set(selectionHandles,'Visible','off');
    return;
end

% Draw the brushing annotations
if ~isempty(I)
    hVis = get(h,'Visible');
    for row=1:size(I,3)
       brushzdata = zdata;
       brushzdata(~I(:,:,row)) = NaN;
       set(selectionHandles(row),'FaceColor',brushColor(row,:),'MarkerFaceColor',...
            brushColor(row,:),'MarkerEdgeColor',brushColor(row,:),...
            'zdata',brushzdata,'xdata',xdata,'ydata',ydata,'LineStyle','-',...
            'visible',hVis);
    end
end   
