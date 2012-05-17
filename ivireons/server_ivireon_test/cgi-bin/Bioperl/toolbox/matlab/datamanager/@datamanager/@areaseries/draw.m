function draw(this,fig)

% Draws brushing annotations

h = this.HGHandle;
if nargin==1
    fig = ancestor(h,'figure');
end
selectionHandles = this.SelectionHandles;
if strcmp(h.RefreshMode,'manual')
    return
end
ydata = get(h,'ydata');
xdata = get(h,'xdata');
ydata = ydata(:);
xdata = xdata(:);

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
    selectionHandles(row) = patch('Parent',get(h,'Parent'),...
        'FaceColor',brushColor(row,:),'linewidth',...
         h.LineWidth+2*row,'linestyle','-','EdgeColor',brushColor(row,:),...
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
    set(selectionHandles,'Visible','off');
end

% Clear brushing if the sizes became incompatible
if ~isempty(I) && (size(I,2)~=length(ydata) || size(I,2)~=length(xdata))
    this.HGHandle.BrushData = [];
    if isa(this.SelectionListener(1), 'handle.listener')
        set(this.SelectionListener,'Enabled','off');
    else
        [this.SelectionListener.Enabled] = deal(false);
    end
    return;
end

% Draw the brushing annotations
if isempty(xdata) || ~isequal(size(ydata),size(xdata))
    set(selectionHandles,'visible','off');
    return;
elseif ~isempty(I)
    hvis = get(h,'Visible');
    for row=1:size(I,1)
       % Clip brushdata to extent of brushed interval
       ind_ = find(I(row,:));
       brush_start = min(ind_);
       brush_end = max(ind_);
       I = I(:,brush_start:brush_end);
       if ~isempty(ind_)>0
           [brushxdata,brushydata,baseydata] = getExtent(this);
           brushydata = brushydata(brush_start:brush_end);
           brushxdata = brushxdata(brush_start:brush_end);
           baseydata = baseydata(brush_start:brush_end);
       else
           set(selectionHandles(row),'visible','off');
           continue;
       end
       
       % Set the brushdata so that the brushed region shows an edge where
       % there is a change from unbrushed to brushed (up_edges) and 
       % an where there is a change from brushed to unbrushed (down_edges)
       brushydata(~I(row,:)) = NaN;%baseydata(~I(row,:)); 
       baseydata(~I(row,:)) = NaN;
       up_edges = [false, diff(double(I(row,:)))>0];
       down_edges = [diff(double(I(row,:)))<0 false];
       brushxdata = [brushxdata brushxdata(up_edges)-10*eps brushxdata(down_edges)+10*eps]; %#ok<AGROW>
       brushydata = [brushydata baseydata(up_edges) baseydata(down_edges)]; %#ok<AGROW>
       baseydata = [baseydata baseydata(up_edges) baseydata(down_edges)]; %#ok<AGROW>
       [brushxdata,Ix] = sort(brushxdata);
       brushydata = brushydata(Ix);
       baseydata = baseydata(Ix);
       
       % If the brushydata contains any NaNs, the brushing annotations
       % must be split into multiple patches which do not contain NaNs.
       % Creates the faces array to capture this.
       INaN = isnan(brushydata);
       nFaces = sum(diff(INaN)==-1)+1;
       nVertices = length(brushydata)-sum(INaN);
       Ileft = [1; find(diff(INaN(:))==-1)+1];
       Iright = [find(diff(INaN(:))==1);length(brushydata)];
       faces = NaN(nFaces,2*max(Iright-Ileft+1));
       ind = 1;
       for k=1:nFaces
           N = -Ileft(k)+Iright(k)+1;
           faces(k,1:N) = ind:(ind+N-1);
           faces(k,N+1:2*N) = (2*nVertices+1) -((ind+N-1):-1:ind) ;
           ind = ind-Ileft(k)+Iright(k)+1;
       end
       % Now create the verices array.
       brushxdata = brushxdata(~INaN);
       brushydata = brushydata(~INaN);
       baseydata = baseydata(~INaN);
       vertices = [brushxdata,brushxdata(end:-1:1); brushydata,baseydata(end:-1:1)]';
       if isempty(vertices)
           set(selectionHandles(row),'Visible','off');
       else
           set(selectionHandles(row),'Vertices',vertices,...
              'Faces',faces,'LineStyle','-',...
              'Visible',hvis,'FaceColor',brushColor(row,:),...
              'EdgeColor',brushColor(row,:));
       end
    end
end