function attachListeners(this)
%handle model related events, such as model added, removed, activated,
%deactivated or renamed.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/02/23 17:16:04 $

messenger = nlutilspack.getMessengerInstance('OldSITBGUI');

L1 = handle.listener(messenger,'identguichange',...
    @(es,ed)localModelChangedCallback(es,ed,this));

sitbgui = getIdentGUIFigure;
L2 = handle.listener(sitbgui,'ObjectBeingDestroyed',@(es,ed)close(this.Figure));

this.Listener = [L1,L2];

%--------------------------------------------------------------------------
function localModelChangedCallback(es,ed,this)

switch ed.propertyName
    case 'nlarxActivated'
         name = get(ed.Info.Model,'name');
        %%
        % If model exists, make its lines visible
        % If model doesn't exist, add it
        %%
        h = find(this.ModelData,'ModelName',name);
        if isempty(h) || ~ishandle(h)
            h = plotpack.nlarxdata(ed.Info.Model,name,ed.Info.isActive);
            h.Color = ed.Info.Color;
            this.addModel(h);
        else
            this.makeModelVisible(name,true);
        end
        
    case 'nlarxDeactivated'
        h = find(this.ModelData,'ModelName',ed.Info);
        if isempty(h) || ~ishandle(h)
            % protection against trash can models
            return;
        end
        this.makeModelVisible(ed.Info,false);
        
    case 'nlarxAdded'
        isActive = ed.Info.isActive;
        % do not add if model is inactive
        if isActive 
            model = ed.Info.Model;
            mobj = plotpack.nlarxdata(model,get(model,'name'),true);
            mobj.Color = ed.Info.Color;
            this.addModel(mobj);
        end
        
    case 'nlarxRemoved'
         this.removeModel(ed.Info); %ed.Info is name of model being removed
        
    case 'nlarxRenamed'
        h = find(this.ModelData,'ModelName',ed.OldValue);
        
        if isempty(h) || ~ishandle(h)
            return;
        end
        
        h.ModelName = ed.NewValue;
        model_lines1 = findall(this.MainPanels,'type','line','tag',ed.OldValue);
        model_lines2 = findall(this.MainPanels,'type','surface','tag',ed.OldValue);
        model_lines = [model_lines1;model_lines2];
        set(model_lines,'tag',h.ModelName);
        
        %update model name in each regressor object
        for k = 1:length(this.RegressorData)
            loc = strmatch(ed.OldValue,this.RegressorData(k).ModelNames,'exact');
            if ~isempty(loc)
                this.RegressorData(k).ModelNames{loc} = h.ModelName;
                for i = 1:length(this.RegressorData(k).RegInfo)
                    loci = strmatch(ed.OldValue,this.RegressorData(k).RegInfo(i).ModelNames,'exact');
                    if ~isempty(loci)
                        this.RegressorData(k).RegInfo(i).ModelNames{loci} = h.ModelName;
                    end
                end
            end
        end
        
        this.updateLegends;
        
    case 'nlarxColorChanged'
        h = find(this.ModelData,'ModelName',ed.Info);
        
        if isempty(h) || ~ishandle(h)
            return;
        end
        
        h.Color = ed.NewValue;
        model_lines1 = findall(this.MainPanels,'type','line','tag',ed.Info);
        model_lines2 = findall(this.MainPanels,'type','surface','tag',ed.Info);
        set(model_lines1,'Color',h.Color);
        
        for k = 1:length(model_lines2)
            Lk = model_lines2(k);
            sz = size(get(Lk,'CData'));
            colmat = [];
            colmat(:,:,1) = repmat(h.Color(1),sz(2),sz(1));
            colmat(:,:,2) = repmat(h.Color(2),sz(2),sz(1));
            colmat(:,:,3) = repmat(h.Color(3),sz(2),sz(1));
            set(Lk,'CData',colmat);
        end
        
        this.updateLegends;
        
    otherwise
        %disp('Unrecognized model change event.')
end

