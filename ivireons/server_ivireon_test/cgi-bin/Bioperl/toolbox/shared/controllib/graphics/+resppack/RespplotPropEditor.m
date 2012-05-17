classdef (Hidden = true) RespplotPropEditor < handle
    % @RespplotPropEditor class definition
    
    %   Copyright 2008 The MathWorks, Inc.
    %	 $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:12:42 $
    properties
        Target
        TargetListeners
        JavaPeer
        hPropEdit
        Title
        VisibilityListeners
        LabelCallBackEnabled
    end

    methods
  
        %% Constructor
        function this = RespplotPropEditor()
            this.buildPanel;
        end

        
        %% Called by Plot Tools specifying target object
        function [JavaPanel,CustomTitle] = initialize(this, TargetObjects)
            if iscell(TargetObjects)
                TargetObjects = [TargetObjects{:}];
            end
            for ct = 1:length(TargetObjects)
                Plots(ct,1) = TargetObjects(ct).Plot;
            end
            %Revisit handle the case where unique is a vector       
            this.setTarget(unique(Plots));
            if numel(this.Target) > 1
                JavaPanel = this.JavaPeer.createMultiPanel;
            else
                JavaPanel = this.JavaPeer.getPanel;
            end
            CustomTitle = getCustomTitle(this);
        end
        
        function CustomTitle = getCustomTitle(this)
            if numel(this.Target)>1
                CustomTitle = ctrlMsgUtils.message('Controllib:plots:strMultipleObjects');
            else
                CustomTitle = regexprep(class(this.Target(1)),'.*\.','');
            end
            
            
        end

        
        %%
        function setTarget(this,TargetObjects)
            % Set target for changes

            % RE: Should check data type of targetobjects

            this.removeTargetListeners
            this.Target = TargetObjects;
            this.installTargetListeners
            this.refreshPanel;
            
            PropEdit = PropEditor(this.Target,'current');             
            if ~isempty(PropEdit) && PropEdit.isVisible
                if numel(TargetObjects) > 1
                    awtinvoke(PropEdit.Java.Frame,'setVisible(Z)',false)
                else
                    PropEdit.setTarget(this.Target)
                end
            end
        end

        
        %%
        function installTargetListeners(this)
            % Install Listeners to target objects
            TargetObjects = this.Target;
            for ct = 1:length(TargetObjects)
                L = handle.listener(TargetObjects(ct).AxesGrid,...
                    TargetObjects(ct).AxesGrid.findprop('Title'),...
                    'PropertyPostSet',{@LocalRefreshTitle this});
                this.addTargetListener(L);
                L = handle.listener(TargetObjects(ct).AxesGrid,...
                    TargetObjects(ct).AxesGrid.findprop('XLabel'),...
                    'PropertyPostSet',{@LocalRefreshXLabel this});
                this.addTargetListener(L);
                L = handle.listener(TargetObjects(ct).AxesGrid,...
                    TargetObjects(ct).AxesGrid.findprop('YLabel'),...
                    'PropertyPostSet',{@LocalRefreshYLabel this});
                this.addTargetListener(L);
     
            end

        end

        
        %%
        function removeTargetListeners(this)
            % Remove Listeners to target objects
            if ~isempty(this.TargetListeners)
                delete(this.TargetListeners(ishandle(this.TargetListeners)))
                this.TargetListeners = [];
            end
        end

        
        %%
        function refreshPanel(this,Type)
            % Refresh Java Panel
            if numel(this.Target) == 1
                if nargin == 1
                    this.refreshPanel('Title')
                    this.refreshPanel('XLabel')
                    this.refreshPanel('YLabel')
                else
                    switch Type
                        case 'Title'
                            Title = this.getTitle;
                            this.JavaPeer.setTitleData(Title);
                        case 'XLabel'
                            XLabel = this.getXLabel;
                            this.JavaPeer.setXLabelData(localReadFormat(XLabel));
                        case 'YLabel'
                            YLabel = this.getYLabel;
                            this.JavaPeer.setYLabelData(localReadFormat(YLabel));
                    end
                end
            end
        end


        %%
        function addTargetListener(this,L)
            % add Listener
            this.TargetListeners = [this.TargetListeners; L];

        end


        %%
        function buildPanel(this)
            % Build panel
            this.JavaPeer = com.mathworks.toolbox.shared.controllib.propertyeditors.RespplotEditorPanelPeer;
            this.JavaPeer.createPanel;
            ButtonCallback = this.JavaPeer.getButtonCallback;
            set(ButtonCallback,'delayedCallback',{@LocalButtonCallback this});
            TitleCallback = this.JavaPeer.getTitleCallback;
            set(TitleCallback,'delayedCallback',{@LocalTitleCallback this});
            XLabelCallback = this.JavaPeer.getXLabelCallback;
            set(XLabelCallback,'delayedCallback',{@LocalXLabelCallback this});
            YLabelCallback = this.JavaPeer.getYLabelCallback;
            set(YLabelCallback,'delayedCallback',{@LocalYLabelCallback this});
        end

        %%
        function Title = getTitle(this)
            % Get Title from Target objects
            Title = this.Target(1).AxesGrid.Title;
            this.Title = Title;
        end
        
        %%
        function XLabel = getXLabel(this)
            % Get XLabel from Target objects
            XLabel = this.Target(1).AxesGrid.XLabel;
        end
        
        %%
        function YLabel = getYLabel(this)
            % Get YLabel from Target objects
            YLabel = this.Target(1).AxesGrid.YLabel;
        end
      
%         function EmptyPanel = getPanelMultiSelect(this)
%             EmptyPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
%             EmptyPanelLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel','Response plots can only be edited one at a time.');
%             javaMethodEDT('add',EmptyPanel,EmptyPanelLabel);
%             drawnow('expose')
%         end
        

    end
end

%%
function localSetVisibility(es, ed, this, b)
this.IsVisible = b;
if b
    this.refreshPanel;
else
    
end
end

%%
function LocalButtonCallback(es,ed,this)
hPropEdit = this.Target.PropEditor;
hPropEdit.setTarget(this.Target);

end

%%
function LocalTitleCallback(es,ed,this)
this.LabelCallBackEnabled = false;
this.Target.AxesGrid.Title = char(ed);
this.LabelCallBackEnabled = true;
end

%%
function LocalXLabelCallback(es,ed,this)
this.LabelCallBackEnabled = false;
this.Target.AxesGrid.XLabel = localWriteFormat(char(ed),this.Target.AxesGrid.XLabel);
this.LabelCallBackEnabled = true;
end

function LocalYLabelCallback(es,ed,this)
this.LabelCallBackEnabled = false;
this.Target.AxesGrid.YLabel = localWriteFormat(char(ed),this.Target.AxesGrid.YLabel);
this.LabelCallBackEnabled = true;
end

%%
function LocalRefreshTitle(es,ed,this)
if this.LabelCallBackEnabled
    this.refreshPanel('Title');
end
end

%%
function LocalRefreshXLabel(es,ed,this)
if this.LabelCallBackEnabled
    this.refreshPanel('XLabel');
end
end


%%
function LocalRefreshYLabel(es,ed,this)
if this.LabelCallBackEnabled
    this.refreshPanel('YLabel');
end
end

%%
function txt = localWriteFormat(txt,CurrentValue)
% Fix carriage return for pc
if ispc, 
   txt = strrep(txt,sprintf('\r\n'),sprintf('\n'));
end  
if iscell(CurrentValue)
   % Multi-entry label
   s = txt;
   txt = cell(size(CurrentValue));
   txt(:) = {''};
   for ct=1:length(CurrentValue)
      [tok,s] = strtok(s,';');
      txt{ct} = fliplr(deblank(fliplr(deblank(tok))));
      s = s(2:end);
      if isempty(s)
         break
      end
   end
end
end


%
function txt = localReadFormat(txt)
if iscell(txt)
   txt = sprintf('%s ; ',txt{:});
   txt = txt(1:end-3);
end
end