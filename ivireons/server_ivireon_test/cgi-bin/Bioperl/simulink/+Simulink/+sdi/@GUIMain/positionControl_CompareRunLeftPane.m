function positionControl_CompareRunLeftPane(this, ~, ~)

    % Copyright 2010 The MathWorks, Inc.
        
    % Cache GUI utilities class
    UG = Simulink.sdi.GUIUtil;
    GC = Simulink.sdi.GeoConst;
    [~, DialogH] = UG.LimitDialogExtents(this.HDialog,        ...
                                         GC.MDefaultDialogHE, ...
                                         GC.MDefaultDialogVE);

    
    p = getpixelposition(this.compareRunsVertSplitter.leftUpPane);
    
    if (p(3) <= GC.mCompareRunsLeft)
        parent = get(this.compareRunsVertSplitter.leftUpPane, 'parent');
        pos = getpixelposition(parent);
        position = GC.mCompareRunsLeft/pos(3);
        this.compareRunsVertSplitter.setPosition(position);        
    end
    
    p = getpixelposition(this.compareRunsVertSplitter.leftUpPane);

    captionWidth = GC.captionWidth;
    captionHeight = GC.captionHeight;
    pushButtonWidth = GC.pushButtonWidth;
    pushButtonHeight = GC.pushButtonHeight;
    gapFromCombo = GC.gapFromCombo;
    gapFromPushButton = GC.gapFromPushButton;
    verticalBuffer = GC.verticalBuffer;
    
    panelWidth = p(3);
    spaceLeftForComboBoxes = panelWidth - captionWidth - pushButtonWidth...
                             - gapFromCombo - gapFromPushButton;
    
    maxWidthCombo = GC.maxWidthCombo;                         
    if spaceLeftForComboBoxes > maxWidthCombo
        spaceLeftForComboBoxes = maxWidthCombo;
    end
    
    if spaceLeftForComboBoxes <= 0
        spaceLeftForComboBoxes = 5; % just to avoid errors with negative values
    end
    
    comboWidth = spaceLeftForComboBoxes;
    
    lhsRunCaptionPos = [GC.IGWindowMarginVE (DialogH-60) captionWidth captionHeight];
    lhsRunComboXPos = GC.IGWindowMarginVE + captionWidth;
       
    LHSRunComboPos = [ lhsRunComboXPos  (DialogH-60) comboWidth pushButtonHeight];
    
    
    rhsRunCaptionXPos = GC.IGWindowMarginVE; % same as lhsRunCaptionPos
    
    rhsRunCaptionYPos = (DialogH-60-captionHeight-verticalBuffer);

    rhsRunCaptionPos = [rhsRunCaptionXPos rhsRunCaptionYPos captionWidth captionHeight];  
    
    rhsRunComboXPos = rhsRunCaptionXPos + captionWidth;
    RHSRunComboPos = [ rhsRunComboXPos rhsRunCaptionYPos comboWidth pushButtonHeight];
    
    plusSignPos = [15 rhsRunCaptionYPos-20 16 16];
    advanceOptPos = [ 40 (rhsRunCaptionYPos-25) 150 20];
        
    compareRunsXPos = gapFromPushButton + rhsRunComboXPos + comboWidth;
    compareRunsPos = [compareRunsXPos rhsRunCaptionYPos pushButtonWidth pushButtonHeight];
    
    set(this.compareRuns, 'pos', compareRunsPos);    
    
    set(this.advanceOptionsPanel, 'pos', [GC.IGWindowMarginVE DialogH-195 500 80]);
    
    set(this.advanceOptions, 'pos', advanceOptPos);
    
    set(this.compareRunAdvancePlus, 'pos', plusSignPos);
    
    set(this.lhsRunCaption, 'pos', lhsRunCaptionPos);
    set(this.rhsRunCaption, 'pos', rhsRunCaptionPos);
    
    set(this.lhsRunCombo, 'pos', LHSRunComboPos);
    set(this.rhsRunCombo, 'pos', RHSRunComboPos);
        
    set(this.alignByCaption, 'pos', [GC.IGWindowMarginVE 60 80 20]);
    set(this.firstThenByCaption, 'pos', [GC.IGWindowMarginVE 30 80 20]);
    set(this.secondThenByCaption, 'pos', [GC.IGWindowMarginVE 0 80 20]);
    
    alignPos = getpixelposition(this.alignByCaption, true);
    firstByPos = getpixelposition(this.firstThenByCaption, true);
    secondByPos = getpixelposition(this.secondThenByCaption, true);
    
    setpixelposition(this.alignByContainer,...
                     [alignPos(1)+60 alignPos(2)-9 80 25]);
    setpixelposition(this.firstThenByContainer,...
                     [firstByPos(1)+60 firstByPos(2)-9 80 25]);
    setpixelposition(this.secondThenByContainer,...
                     [secondByPos(1)+60 secondByPos(2)-9 80 25]);
    
    str = get(this.compareRunAdvancePlus, 'String');
    if strcmp(str, '+')
        set(this.compareRunsTT.container, 'pos', [GC.IGWindowMarginVE GC.IGWindowMarginVE p(3)-20 (DialogH-125)]);
    elseif strcmp(str, '-')
        set(this.compareRunsTT.container, 'pos', [GC.IGWindowMarginVE GC.IGWindowMarginVE p(3)-20 (DialogH-215)]);
    end
    
    
end
