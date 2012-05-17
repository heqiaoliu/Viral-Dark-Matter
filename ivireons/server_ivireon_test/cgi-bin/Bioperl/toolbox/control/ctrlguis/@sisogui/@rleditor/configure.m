function configure(this,varargin)
% Reconfigures editor when configuration or target changes

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2010/05/10 16:59:24 $
if strcmp(this.Visible,'on')
   [L,idxL] = getL(this);
   
   % Update title
   if isempty(L.Name) || strcmp(L.Name,L.Identifier)
      this.Axes.Title = sprintf('Root Locus Editor for %s',L.Identifier);
   else
      this.Axes.Title = sprintf('Root Locus Editor for %s (%s)',L.Name,L.Identifier);
   end
   % Updates editor's dependency list REVISIT
   this.Dependency = this.getDependency; 
   
   % Initialize Targets
   this.initializeCompTarget;
   
   % If FRD loop turn editor off
   if hasFRD(L)
       this.setEnabled(false);
       this.Axes.showMessagePane(true,localFRDMessage());
       % Revisit need to clear data.
       this.clear;
   else
       this.setEnabled(true);
       if hasDelay(L) && isequal(L.Ts,0)
          this.Axes.showMessagePane(true,localTimeDelayMessage(this));
       else
          this.Axes.showMessagePane(false); 
       end
   end
   
   % Turn on multi-model characteristics
   if isUncertain(L) 
       % Enable Multi Model Menu
       setmenu(this,'on','multiplemodel')
       % If not visible show menu
       if ~this.UncertainBounds.isVisible
           this.UncertainBounds.Visible = 'on';
           this.update;
       end
   else
       % Disable Multi Model Menu
       setmenu(this,'off','multiplemodel')
       this.UncertainBounds.Visible = 'off';
   end
   
end
end


function MessageTextPane = localTimeDelayMessage(this)

Msg = ctrlMsgUtils.message('Control:compDesignTask:strNotificationRootLocusTimeDelay');
MessageTextPane = ctrluis.PopupPanel.createMessageTextPane(Msg,get(0,'DefaultTextFontName'),11);
h = handle(MessageTextPane, 'callbackproperties');
h.HyperlinkUpdateCallback = {@localPrefCallback, this};
end



function MessageTextPane = localFRDMessage()
Msg = ctrlMsgUtils.message('Control:compDesignTask:strNotificationRootLocusFRD');
MessageTextPane = ctrluis.PopupPanel.createMessageTextPane(Msg,get(0,'DefaultTextFontName'),11);
end


function localPrefCallback(es,ed,this) %#ok<INUSL>

if strcmp(ed.getEventType.toString, 'ACTIVATED')
    % Determine Hyperlink Description
    Description = char(ed.getDescription);
    switch Description
        case 'Pref'
            % Open Preference Editor to the Options tab.
            this.up.Preference.edit;
            this.up.Preference.selecttab('TimeDelays');
    end
end
end