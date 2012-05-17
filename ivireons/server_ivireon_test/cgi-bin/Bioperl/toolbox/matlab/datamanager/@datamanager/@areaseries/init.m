function init(this,h)

% Overridden init method redraws all peers when any one of them sees a
% change in xdata or ydata. This is needed since the areas are stacked and
% a chnage in one layer of the stack necessitates re-positioning the 
% brushing annotations for all the layers.

this.HGHandle = handle(h);
setappdata(double(h),'Brushing__',this);

% If necessary create BrushData instance property for HG
if isempty(this.HGHandle.findprop('BrushData'))
    if feature('HGUsingMATLABClasses')
        p = addprop(this.HGHandle,'BrushData');
        p.Transient = true;
    else
        p = schema.prop(this.HGHandle,'BrushData','MATLAB array');
        p.AccessFlags.Serialize = 'off';
    end
end
hFig = handle(ancestor(this.HGHandle,'figure'));
if isempty(hFig.findprop('BrushStyleMap'))
    if feature('HGUsingMATLABClasses')
        addprop(hFig,'BrushStyleMap');
    else    
        schema.prop(hFig,'BrushStyleMap','MATLAB array');
    end
   hFig.BrushStyleMap = [1 0 0;0 1 0; 0 0 1]; % default
end

% Add listeners with anonamous function handles which do not contain the
% other listeners as internal state.
localAddSelectionListener(this,h);
localAddDataListener(this,h);
localAddDeleteListener(this,h);
if isempty(this.CleanupListener)
    this.CleanupListener = handle.listener(this,'ObjectBeingDestroyed',...
        {@localCleanup this}); 
end 

if ~isempty(this.HGHandle.BrushData)
    this.draw;
end

function localDeleteBrushing(this)

delete(this.SelectionHandles(ishghandle(this.SelectionHandles)));
this.SelectionHandles = [];

function localDraw(this)

peers = get(this.HGHandle,'AreaPeers');
for k=1:length(peers)
    bObj = getappdata(double(peers(k)),'Brushing__');
    if ~isempty(bObj)
        bObj.draw
    end
end

function localCleanup(es,ed,this) %#ok<INUSL>

delete(this.SelectionListener);
delete(this.DataListener);
delete(this.DeleteListener);
this.SelectionListener = [];
this.DataListener = [];
this.DeleteListener = [];

function localAddSelectionListener(this,h)

if isempty(this.SelectionListener)
     this.SelectionListener = addlistener(h,{'XData','YData','Visible'},...
            'PostSet',@(es,ed) localDraw(this));
end

function localAddDataListener(this,h)

if isempty(this.DataListener)
     this.DataListener = addlistener(h,'BrushData',...
         'PostSet',@(es,ed) draw(this));
end

function localAddDeleteListener(this,h)

if isempty(this.DeleteListener)
    this.DeleteListener = addlistener(h,'ObjectBeingDestroyed',...
        @(es,ed) localDeleteBrushing(this)); 
end
