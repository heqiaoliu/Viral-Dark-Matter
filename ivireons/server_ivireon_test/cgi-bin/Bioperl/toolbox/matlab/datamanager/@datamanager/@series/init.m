function init(this,h)

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

this.draw;


function localAddSelectionListener(this,h)

if isempty(this.SelectionListener)
    if isempty(h.findprop('ZData'))
        this.SelectionListener = addlistener(h,{'XData','YData','Visible'},...
            'PostSet',@(es,ed) localDraw(this));
    else
        this.SelectionListener = addlistener(h,{'XData','YData','ZData','Visible'},...
            'PostSet',@(es,ed) localDraw(this));
    end
end

function localAddDeleteListener(this,h)

if isempty(this.DeleteListener)
    this.DeleteListener = addlistener(h,'ObjectBeingDestroyed',...
        @(es,ed) localDeleteBrushing(this)); 
end

function localAddDataListener(this,h)

if isempty(this.DataListener)
     this.DataListener = addlistener(h,'BrushData',...
         'PostSet',@(es,ed) draw(this));
end

function localCleanup(es,ed,this) %#ok<INUSL>

delete(this.SelectionListener);
delete(this.DataListener);
delete(this.DeleteListener);
this.SelectionListener = [];
this.DataListener = [];
this.DeleteListener = [];