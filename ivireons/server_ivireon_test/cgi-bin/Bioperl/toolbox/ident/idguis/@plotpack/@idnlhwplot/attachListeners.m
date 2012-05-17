function attachListeners(this)
%handle model related events, such as model added, removed, activated,
%deactivated or renamed. This method supports GUI operations.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/02/06 19:52:29 $

messenger = nlutilspack.getMessengerInstance('OldSITBGUI');

L1 = handle.listener(messenger,'identguichange',...
    @(es,ed)localModelChangedCallback(es,ed,this));

sitbgui = getIdentGUIFigure;
L2 = handle.listener(sitbgui,'ObjectBeingDestroyed',@(es,ed)close(this.Figure));

this.Listeners = [this.Listeners,L1,L2];

%--------------------------------------------------------------------------
function localModelChangedCallback(es,ed,this)

switch ed.propertyName
    case 'nlhwActivated'
        name = get(ed.Info.Model,'name');
        %%
        % If model exists, make its lines visible
        % If model doesn't exist, add it
        %%
        h = find(this.ModelData,'ModelName',name);
        if isempty(h) || ~ishandle(h)
            h = plotpack.nlhwdata(ed.Info.Model,name,ed.Info.isActive);
            h.Color = ed.Info.Color;
            this.addModel(h);
        else
            this.makeModelVisible(name,true);
        end
                
    case 'nlhwDeactivated'
        h = find(this.ModelData,'ModelName',ed.Info);
        if isempty(h) || ~ishandle(h)
            return;
        end
        
        this.makeModelVisible(ed.Info,false);
        
    case 'nlhwAdded'
        isActive = ed.Info.isActive;
        % do not add if model is inactive
        if isActive 
            model = ed.Info.Model;
            mobj = plotpack.nlhwdata(model,get(model,'name'),true);
            mobj.Color = ed.Info.Color;
            this.addModel(mobj);
        end    
                
    case 'nlhwRemoved'
        this.removeModel(ed.Info); %ed.Info is name of model being removed
        
    case 'nlhwRenamed'
        h = find(this.ModelData,'ModelName',ed.OldValue);
        
        if isempty(h) || ~ishandle(h)
            return;
        end
        
        h.ModelName = ed.NewValue;
        model_lines = findall(this.MainPanels,'type','line','tag',ed.OldValue);
        set(model_lines,'tag',h.ModelName);
        
        localUpdateLegends(this);
        
    case 'nlhwColorChanged'
        h = find(this.ModelData,'ModelName',ed.Info);
        
        if isempty(h) || ~ishandle(h)
            return;
        end
        
        h.Color = ed.NewValue;
        model_lines = findall(this.MainPanels,'type','line','tag',ed.Info);
        set(model_lines,'Color',h.Color);
        
        localUpdateLegends(this);
        
    otherwise
        %disp('Unrecognized model change event.')
end

%--------------------------------------------------------------------------
function localUpdateLegends(this)

Ax = findobj(this.MainPanels,'type','axes');
for k = 1:length(Ax)
    axtype = get(Ax(k),'user');
    if any(strcmpi(axtype,{'step','impulse','bode','pzmap'})) ||...
            strncmp(axtype,'nonlinear',9)
        this.addLegend(Ax(k));
    end
end