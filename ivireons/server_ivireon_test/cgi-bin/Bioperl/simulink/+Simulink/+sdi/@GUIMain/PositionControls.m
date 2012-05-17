function PositionControls(this)
    
    % Copyright 2009-2010 The MathWorks, Inc.

    % call all the resizers
    this.positionControl_CompareRunLeftPane([], []);
    this.positionControl_CompareRunRightPane([], []);
    this.positionControl_CompareSignalsLeftPane([], []);
    this.positionControl_CompareSignalsRightPane([], []);
    this.positionControl_InspectSignalsLeftPane([], []);
    this.positionControl_InspectSignalsRightPane([], []);
    this.positionControls_OptionsButton();
end