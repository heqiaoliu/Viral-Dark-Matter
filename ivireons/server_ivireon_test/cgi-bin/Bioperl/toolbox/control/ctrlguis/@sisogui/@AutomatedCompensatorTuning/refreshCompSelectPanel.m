function refreshCompSelectPanel(this)
%REFRESHCOMPSELECTPANEL  Refresh the compensator selection panel of a tuning method.

%   Author(s): R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2006/12/27 20:33:57 $

%% Get GUI component handles in the compensator selection panel
Handles = this.CompSelectPanelHandles;

%% Update component combo box if necessary
if this.IsConfigChanged
    % populate the compensator combo box
    ComboAll = Handles.CompComboBox;
    % disable the combo callback
    hdl = Handles.CompComboBoxListener;
    hdl.Enabled = 'off';
    % rebuild combo box
    awtinvoke(ComboAll,'removeAllItems()');
    if ~isempty(this.TunedCompList)
        for ct = 1:length(this.TunedCompList)
            if isempty(this.TunedCompList(ct).Name)
                awtinvoke(ComboAll,'addItem(Ljava/lang/Object;)',this.TunedCompList(ct).Identifier);
            else
                awtinvoke(ComboAll,'addItem(Ljava/lang/Object;)',this.TunedCompList(ct).Name);
            end
        end
        % initialize selection index
        this.IdxC = 1;
        awtinvoke(ComboAll,'setSelectedIndex(I)',this.IdxC-1);
        % update open loop plant
        this.IsOpenLoopPlantDirty = true;
    end
    % reset dirty flag
    this.IsConfigChanged = false;
    % renable callback
    hdl.Enabled = 'on';
end

%% get current selected compensator index
if isempty(this.TunedCompList)
    awtinvoke(Handles.CompComboBox,'setVisible(Z)',false);    
    awtinvoke(Handles.CompEqualLabel,'setVisible(Z)',false);    
    awtinvoke(Handles.CompGainLabel,'setVisible(Z)',false);    
    tmpStr = sprintf('<html><center>%s %s</center></html>',...
        xlate('The compensators you specified are not tunable by automated tuning methods.'),...
        xlate('To tune a pure gain block, use graphical tuning tools.'));
    awtinvoke(Handles.CompPZLabel, 'setText(Ljava/lang/String;)', java.lang.String(tmpStr));    
else
    awtinvoke(Handles.CompComboBox,'setVisible(Z)',true);    
    awtinvoke(Handles.CompEqualLabel,'setVisible(Z)',true);    
    awtinvoke(Handles.CompPZLabel,'setVisible(Z)',true);    
    % get compensator
    compensator = this.TunedCompList(this.IdxC);
    % get new gain
    gain = compensator.getFormattedGain;
    % get new pole/zero expression for display
    [ZString PString] = compensator.getDisplayString;
    % display pole/zero first
    if isempty(ZString) && isempty(PString)
        % Three line breaks
        awtinvoke(Handles.CompPZLabel,'setToolTipText(Ljava/lang/String;)','');
        PZString = sprintf('<html><BR><BR><BR></html>');
    else
        if compensator.Ts>0 && ismember(this.parent.parent.preferences.CompensatorFormat,{'TimeConstant1','TimeConstant2'})
            WString = sprintf('w=(z-1)/Ts');
            awtinvoke(Handles.CompPZLabel, 'setToolTipText(Ljava/lang/String;)',java.lang.String(WString));    
            PZString = sprintf('<html><table><td><center>%s</center><hr><center>%s</center></td><td>, %s</td></table></html>', ZString, PString, WString);
        else
            awtinvoke(Handles.CompPZLabel,'setToolTipText(Ljava/lang/String;)','');
            PZString = sprintf('<html><center>%s</center><hr><center>%s</center></html>', ZString, PString);            
        end
    end
    awtinvoke(Handles.CompPZLabel, 'setText(Ljava/lang/String;)', java.lang.String(PZString));
    % display gain next
    if isempty(ZString) && isempty(PString)
        GainLabelText = sprintf(this.PrecisionFormat,gain);
    else
        GainLabelText = strcat(sprintf(this.PrecisionFormat,gain),' x ');
    end
    awtinvoke(Handles.CompGainLabel,'setText(Ljava/lang/String;)',java.lang.String(GainLabelText));
end    
