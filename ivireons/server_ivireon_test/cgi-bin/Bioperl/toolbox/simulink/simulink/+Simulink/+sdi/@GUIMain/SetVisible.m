function SetVisible(this)
    
    % Copyright 2009-2010 The MathWorks, Inc.
    
    % Cache util class
    UT = Simulink.sdi.Util;
    
    % Cache tab index
    TT = this.GetTabType();

    % Get tab state
    IsInspectSignalsTab = TT == Simulink.sdi.GUITabType.InspectSignals;
    IsCompareSignalsTab = TT == Simulink.sdi.GUITabType.CompareSignals;
    IsCompareRunsTab    = TT == Simulink.sdi.GUITabType.CompareRuns;
    IsAnyCompareTab     = IsCompareSignalsTab || IsCompareRunsTab;
    
    % Convert booleans to on off
    InspectSignalsTabOnOff = UT.BoolToOnOff(IsInspectSignalsTab);
    CompareSignalsTabOnOff = UT.BoolToOnOff(IsCompareSignalsTab);
    CompareRunsTabOnOff    = UT.BoolToOnOff(IsCompareRunsTab);
    AnyCompareTabOnOff     = UT.BoolToOnOff(IsAnyCompareTab);
    
    % get visibility of all the panes
    inspLeft = get(this.inspectSplitter.leftUpPane, 'vis');
    inspRight = get(this.inspectSplitter.rightDownPane, 'vis');
    
    compareSigRight1 = get(this.compareSigHorSplitter.rightDownPane, 'vis');
    compareSigRight2 = get(this.compareSigHorSplitter.leftUpPane, 'vis');
    
    compareSigRight = get(this.compareSigVertSplitter.rightDownPane, 'vis');
    compareSigLeft = get(this.compareSigVertSplitter.leftUpPane, 'vis');
    
    compareRunRight1 = get(this.compareRunsHorSplitter.rightDownPane, 'vis');
    compareRunRight2 = get(this.compareRunsHorSplitter.leftUpPane, 'vis');
    
    compareRunRight = get(this.compareRunsVertSplitter.rightDownPane, 'vis');
    compareRunLeft = get(this.compareRunsVertSplitter.leftUpPane, 'vis');
    
    % set visible Inspect Signals components
    if(strcmpi(inspLeft, 'on'))
        set(this.InspectTT.container, 'Visible',InspectSignalsTabOnOff);    
    else
        set(this.InspectTT.container, 'Visible','off');    
    end
    
    this.inspectSplitter.setVisibility(InspectSignalsTabOnOff);
    
    % set visible Compare Signals components
    this.compareSigVertSplitter.setVisibility(CompareSignalsTabOnOff);
        
    if(strcmpi(compareSigRight, 'on'))
        this.compareSigHorSplitter.setVisibility(CompareSignalsTabOnOff);
    else
        this.compareSigHorSplitter.setVisibility('off');
    end
    
    if(strcmpi(compareSigLeft, 'on'))
        set(this.compareSignalsTT.container, 'Visible', CompareSignalsTabOnOff);
    else
        set(this.compareSignalsTT.container, 'Visible', 'off');
    end
    
    % set visible Compare Runs components
    this.compareRunsVertSplitter.setVisibility(CompareRunsTabOnOff);  
    
    if(strcmpi(compareRunRight, 'on'))
        this.compareRunsHorSplitter.setVisibility(CompareRunsTabOnOff);
    else
        this.compareRunsHorSplitter.setVisibility('off');
    end
    
    if(strcmpi(compareRunLeft, 'on'))
        this.compareRunsHorSplitter.setVisibility(CompareRunsTabOnOff);
        set(this.lhsRunContainer, 'vis', CompareRunsTabOnOff);
        set(this.rhsRunContainer, 'vis', CompareRunsTabOnOff);
        set(this.compareRunsTT.container, 'vis', CompareRunsTabOnOff);
        set(this.alignByContainer, 'vis', CompareRunsTabOnOff);
        set(this.firstThenByContainer, 'vis', CompareRunsTabOnOff);
        set(this.secondThenByContainer, 'vis', CompareRunsTabOnOff);
    else
        this.compareRunsHorSplitter.setVisibility('off');
        set(this.lhsRunContainer, 'vis', 'off');
        set(this.rhsRunContainer, 'vis', 'off');
        set(this.compareRunsTT.container, 'vis', 'off');
        set(this.alignByContainer, 'vis', 'off');
        set(this.firstThenByContainer, 'vis', 'off');
        set(this.secondThenByContainer, 'vis', 'off');
    end
        
%     set(this.OptionsMenuButton2Container, 'visible', AnyCompareTabOnOff);
    
    isAdvPanelVis = get(this.advanceOptionsPanel, 'vis');
    
    if (strcmpi(isAdvPanelVis,'on') && IsCompareRunsTab && strcmpi(compareRunLeft, 'on'))
        set(this.alignByContainer, 'vis', 'on');
        set(this.firstThenByContainer, 'vis', 'on');
        set(this.secondThenByContainer, 'vis', 'on');
    else
        set(this.alignByContainer, 'vis', 'off');
        set(this.firstThenByContainer, 'vis', 'off');
        set(this.secondThenByContainer, 'vis', 'off');
    end
    
    this.positionControls_OptionsButton();        
    this.transferStateToScreen_tableContextMenuCheckMarks();    
    drawnow;
end