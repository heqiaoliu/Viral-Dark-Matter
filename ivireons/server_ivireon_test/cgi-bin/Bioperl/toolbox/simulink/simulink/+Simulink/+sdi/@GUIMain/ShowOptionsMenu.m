function ShowOptionsMenu(this, TabType, AxesResultType)

    % Copyright 2009-2010 The MathWorks, Inc.

    % Which options button?
    switch AxesResultType
    case Simulink.sdi.GUIAxesResultType.Signals
        OptionsButton = this.OptionsMenuButton1Container;
    case Simulink.sdi.GUIAxesResultType.Diff
        OptionsButton = this.OptionsMenuButton2Container;
    end

    % Determine if the originating axes is using
    % the original scale or is normalized
    AxesID    = this.ResolveAxesID(TabType, AxesResultType);
    AxesYType = this.GetAxesYType(AxesID);
    
    switch AxesID
        case Simulink.sdi.AxesID.InspectSignalsData
            normalized = this.normInspectAxes;
            plotStyle = this.stairLineInspectAxes;
        case Simulink.sdi.AxesID.CompareSignalsData
            normalized = this.normCompSigDataAxes;
            plotStyle = this.stairLineCompSigDataAxes;
        case Simulink.sdi.AxesID.CompareSignalsDiff
            normalized = this.normCompSigDiffAxes;
            plotStyle = this.stairLineCompSigDiffAxes;
        case Simulink.sdi.AxesID.CompareRunsData
            normalized = this.normCompRunsDataAxes;
            plotStyle = this.stairLineCompRunsDataAxes;
        case Simulink.sdi.AxesID.CompareRunsDiff
            normalized = this.normCompRunsDiffAxes;
            plotStyle = this.stairLineCompRunsDiffAxes;
    end
    
    % Convert Axes type into menu-friendly on/off strings

    originalOnOff   = Simulink.sdi.Util.BoolToOnOff(~normalized);
    normalizedOnOff = Simulink.sdi.Util.BoolToOnOff(normalized);
    linePlot        = Simulink.sdi.Util.BoolToOnOff(plotStyle);
    stairPlot        = Simulink.sdi.Util.BoolToOnOff(~plotStyle);
    
    % Update checkmarks on menu
    set(this.OptionsMenuOriginal,  'checked', originalOnOff);
    set(this.OptionsMenuNormalize, 'checked', normalizedOnOff);
    set(this.optionsMenuStairPlot, 'checked', stairPlot);
    set(this.optionsMenuLinePlot,  'checked', linePlot);

    % Tag the menu so we'll know the origin inside the callback
    UserData.AxesID    = AxesID;
    UserData.AxesYType = AxesYType;
    set(this.OptionsMenu, 'userdata', UserData);

    % Get position of button
    ButtonPos = getpixelposition(OptionsButton,true);

    % Set position of menu directly under button
    set(this.OptionsMenu, 'pos',[ButtonPos(1), ButtonPos(2)]);

    % Show menu
    set(this.OptionsMenu, 'Visible', 'on');
end