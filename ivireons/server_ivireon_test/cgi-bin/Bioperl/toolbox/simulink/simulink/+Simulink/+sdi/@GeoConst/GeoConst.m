classdef GeoConst
  
  % Copyright 2009-2010 The MathWorks, Inc.
  
  % Static properties
  properties (Constant = true)
    %----------------------------------------------------------------------
    % MAIN SDI GUI Constants
    
    MDefaultDialogHE = 450;%800
    MDefaultDialogVE = 350;%600
    
    MMinDialogHE = 900;
    MMinDialogVE = 700;
    
    MWindowMarginHE = 10;
    MWindowMarginVE = 10;
    
    MTreeTableHE = 295;
    MTreeTableVE = 350;
    
    MAxesHE       = 395;
    MAxesVE       = 250;
    MAxesGapVE    = 25;
    MAxesNumGapVE = 20;
    
    InBetweenAxesGap  = 90;
    MTreeTAxesGapHE   = 90;
    MTreeTTolTabGapVE = 45;
    
    MTolTabHE = 295;
    MTolTabVE = 170;
    
    %minimum width of LHS panel in Compare Runs Tab
    mCompareRunsLeft = 300;
    
    diffDialogPlus = 215;
    diffDialogMinus = 125;
    
    % Axes margins
    mBottomAxesMargin = 45;
    mVerticalAxesMargin = 30;
    mHorAxesDiffFromParent = 60;
    mVertAxesDiffFromParent = 60;
    
    % option button
    mOptionWidth = 80;
    mOptionHeight = 20;
    % How much does the inspect axes grow with respect to default axes.
    InspInc = 100;
    
    % default axes position
    defaultAxesPos = [0.1300 0.1100 0.7750 0.8150];
    
    % ********************
    % **** Import GUI ****
    % ********************

    % Dialog
    IGDefaultDialogHE = 600;  % Default dialog horizontal extent
    IGDefaultDialogVE = 500;  % Default dialog vertical extent
    IGMinDialogHE     = 500;  % Minimum dialog horizontal extent
    IGMinDialogVE     = 350;  % Minimum dialog vertical extent
    IGWindowMarginHE  =  10;  % Window margin horizontal extent
    IGWindowMarginVE  =  10;  % Window margin vertical extent
    
    % Controls - Common
    IGTextVE  = 20; % Height of a single line of text
    IGRadioVE = 20; % Height of a radio button
    IGEditVE  = 23; % Height of a text edit
    IGComboVE = 20; % Height of a combo box
    
    % Input margins
    IGInputMarginMinorVE = 10; % Minor vertical space between input controls
    IGInputMarginMajorVE = 20; % Major vertical space between input sections
    
    % "Import From" section
    IGImportFromLabelHE     = 150; % Width of the "Import from" label
    IGImportFromRadioHE     = 150; % Width of the "Import from" radios
    IGImportFromMATLabelHE  =  70; % Width of MAT "File name" label
    IGImportFromMATLabelHG  =  20; % Horizontal gap of MAT "File name" label
    IGImportFromMATEditHE   = 300; % Width of MAT edit field
    IGImportFromMATButtonHE =  30; % Width of MAT edit button

    % "Import To" section
    IGImportToRunNameHE  =  70; % Width of "Run name" label
    IGImportToRunNameHG  =  20; % Horizontal gap of "Run name" label
    IGImportToRunComboHE = 330; % Width of run combo

    % Refresh, select all, clear all buttons
    IGRSCButtonHE = 105; % Horizontal extent
    IGRSCButtonVE =  30; % Vertical extent
    IGRSCButtonHG =  10; % Horizontal gap between buttons
    IGRSCButtonVG =  10; % Vertical gap between buttons and controls
    
    % OK, Cancel, Help buttons
    IGOCHButtonHE = 70; % Horizontal extent
    IGOCHButtonVE = 30; % Vertical extent
    IGOCHButtonHG = 10; % Horizontal gap between buttons
    IGOCHButtonVG = 10; % Vertical gap between buttons and controls

    % *******************************
    % **** Signal Properties GUI ****
    % *******************************

    SPDefaultDialogHE = 600;  % Default dialog horizontal extent
    SPDefaultDialogVE = 400;  % Default dialog vertical extent
    SPMinDialogHE     = 400;  % Minimum dialog horizontal extent
    SPMinDialogVE     = 200;  % Minimum dialog vertical extent
    SPWindowMarginHE  =  10;  % Window margin horizontal extent
    SPWindowMarginVE  =  10;  % Window margin vertical extent
    
    SPOKButtonHE = 70; % OK button width
    SPOKButtonVE = 30; % OK button height
    SPOKButtonVG = 10; % Vertical gap between button and controls

    % ***********************
    % **** Alignment GUI ****
    % ***********************

    DefaultDialogHE = 1000; % Default dialog horizontal extent
    DefaultDialogVE =  500; % Default dialog vertical extent
    MinDialogHE     =  800; % Minimum dialog horizontal extent
    MinDialogVE     =  400; % Minimum dialog vertical extent
    WindowMarginHE  =    5; % Window margin horizontal extent
    WindowMarginVE  =   10; % Window margin vertical extent
    
    % Drop downs
    DropDownVE = 20;   % Run drop down vertical extent
    DropDownHG = 10;
    
    % OK, Cancel, Help buttons
    OCHButtonHE = 100;
    OCHButtonVE = 40;
    OCHButtonHG = 10;
    
    % Load and Save buttons
    LSButtonHE = 120;
    LSButtonVE =  40;
    LSButtonHG =  10;
    
    % Validate button
    VButtonHE = 100;
    VButtonVE =  40;
    
    % Button
    ButtonGroupVG = 20; 
    
    % position control left pane compare runs
    captionWidth = 60;
    captionHeight = 20;
    pushButtonWidth = 70;
    pushButtonHeight = 25;
    gapFromCombo = 30;
    gapFromPushButton = 20;
    verticalBuffer = 5;
    maxWidthCombo = 420;     
    
    % Tree table
    TTVG = 10;
  end % properties
  
end % class GeoConst