function Show(this)

    % Copyright 2009-2010 The MathWorks, Inc.

    % Safely create controls in case of bad handles
    this.Build();
    
    % has to set this again as it got reset in
    % positionControl_CompareRunLeftPane
    this.compareRunsVertSplitter.dividerLocation = 0.5;                  
    this.compareRunsVertSplitter.dividerLocationUpdate = 0.5;
    
    % Set visible flag
    set(this.HDialog, 'visible', 'on');                      

    % Force processing of draw messages
    drawnow;
end