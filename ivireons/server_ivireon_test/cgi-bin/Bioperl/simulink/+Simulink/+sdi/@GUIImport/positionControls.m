function positionControls(this)

    % Layout the position and extent of the controls
    %
    % Copyright 2009-2010 The MathWorks, Inc.
    
    % Cache geometric constants class
    GC = Simulink.sdi.GeoConst;
    
    % Cache GUI utilities class
    UG = Simulink.sdi.GUIUtil;
    
    % Enforce minimum dialog extents
    [DialogW, DialogH] = UG.LimitDialogExtents(this.HDialog,     ...
                                               GC.IGMinDialogHE, ...
                                               GC.IGMinDialogVE);
    
    % ********************************
    % **** Common Dialog Controls ****
    % ********************************

    % OK, Cancel and Help Buttons
    OKButtonX   = DialogW - GC.IGWindowMarginHE ...
                  - (3 * GC.IGOCHButtonHE) - (2 * GC.IGOCHButtonHG);
    OKButtonY   = GC.IGWindowMarginVE;
    OKButtonW   = GC.IGOCHButtonHE;
    OKButtonH   = GC.IGOCHButtonVE;
    OKButtonPos = [OKButtonX, OKButtonY, OKButtonW, OKButtonH];
    
    CancelButtonX   = DialogW - GC.IGWindowMarginHE ...
                      - (2 * GC.IGOCHButtonHE) - GC.IGOCHButtonHG;
    CancelButtonY   = OKButtonY;
    CancelButtonW   = GC.IGOCHButtonHE;
    CancelButtonH   = GC.IGOCHButtonVE;
    CancelButtonPos = [CancelButtonX, CancelButtonY, ...
                       CancelButtonW, CancelButtonH];
    
    HelpButtonX   = DialogW - GC.IGWindowMarginHE - GC.IGOCHButtonHE;
    HelpButtonY   = OKButtonY;
    HelpButtonW   = GC.IGOCHButtonHE;
    HelpButtonH   = GC.IGOCHButtonVE;
    HelpButtonPos = [HelpButtonX, HelpButtonY, HelpButtonW, HelpButtonH];
    
    % *******************************
    % **** "Import from" section ****
    % *******************************

    ImportFromLabelX   = GC.IGWindowMarginHE;
    ImportFromLabelY   = DialogH - GC.IGWindowMarginVE - GC.IGTextVE;
    ImportFromLabelW   = GC.IGImportFromLabelHE;
    ImportFromLabelH   = GC.IGTextVE;
    ImportFromLabelPos = [ImportFromLabelX, ImportFromLabelY, ...
                          ImportFromLabelW, ImportFromLabelH];
    
    ImportFromBaseRadioX   = ImportFromLabelX + ImportFromLabelW;
    ImportFromBaseRadioY   = ImportFromLabelY;
    ImportFromBaseRadioW   = GC.IGImportFromRadioHE;
    ImportFromBaseRadioH   = GC.IGRadioVE;
    ImportFromBaseRadioPos = [ImportFromBaseRadioX, ImportFromBaseRadioY, ...
                              ImportFromBaseRadioW, ImportFromBaseRadioH];
    
    ImportFromMATRadioX   = ImportFromBaseRadioX;
    ImportFromMATRadioY   = ImportFromBaseRadioY       ...
                            - GC.IGRadioVE             ...
                            - GC.IGInputMarginMinorVE;
    ImportFromMATRadioW   = GC.IGImportFromRadioHE;
    ImportFromMATRadioH   = GC.IGRadioVE;
    ImportFromMATRadioPos = [ImportFromMATRadioX, ImportFromMATRadioY, ...
                             ImportFromMATRadioW, ImportFromMATRadioH];
    
    ImportFromMATLabelX   = ImportFromMATRadioX + GC.IGImportFromMATLabelHG;
    ImportFromMATLabelY   = ImportFromMATRadioY - GC.IGEditVE ...
                            - GC.IGInputMarginMinorVE;
    ImportFromMATLabelW   = GC.IGImportFromMATLabelHE;
    ImportFromMATLabelH   = GC.IGTextVE;
    ImportFromMATLabelPos = [ImportFromMATLabelX, ImportFromMATLabelY, ...
                             ImportFromMATLabelW, ImportFromMATLabelH];
    
    ImportFromMATEditX   = ImportFromMATLabelX + ImportFromMATLabelW;
    ImportFromMATEditY   = ImportFromMATLabelY;
    ImportFromMATEditW   = GC.IGImportFromMATEditHE;
    ImportFromMATEditH   = GC.IGEditVE;
    ImportFromMATEditPos = [ImportFromMATEditX, ImportFromMATEditY, ...
                            ImportFromMATEditW, ImportFromMATEditH];
    
    ImportFromMATButtonX   = ImportFromMATEditX + ImportFromMATEditW;
    ImportFromMATButtonY   = ImportFromMATEditY;
    ImportFromMATButtonW   = GC.IGImportFromMATButtonHE;
    ImportFromMATButtonH   = ImportFromMATEditH;
    ImportFromMATButtonPos = [ImportFromMATButtonX, ImportFromMATButtonY, ...
                              ImportFromMATButtonW, ImportFromMATButtonH];
    
    % *******************************
    % **** "Import to" section ****
    % *******************************
    
    ImportToLabelX = ImportFromLabelX;
    ImportToLabelY = ImportFromMATEditY - GC.IGTextVE - GC.IGInputMarginMajorVE;
    ImportToLabelW = GC.IGImportFromLabelHE;
    ImportToLabelH = GC.IGTextVE;
    ImportToLabelPos = [ImportToLabelX, ImportToLabelY, ...
                        ImportToLabelW, ImportToLabelH];
    
    ImportToNewRadioX = ImportFromBaseRadioX;
    ImportToNewRadioY = ImportToLabelY;
    ImportToNewRadioW = GC.IGImportFromRadioHE;
    ImportToNewRadioH = GC.IGRadioVE;
    ImportToNewRadioPos = [ImportToNewRadioX, ImportToNewRadioY, ...
                           ImportToNewRadioW, ImportToNewRadioH];
    
    ImportToExistRadioX   = ImportToNewRadioX;
    ImportToExistRadioY   = ImportToNewRadioY - GC.IGRadioVE ...
                            - GC.IGInputMarginMinorVE;
    ImportToExistRadioW   = GC.IGImportFromRadioHE;
    ImportToExistRadioH   = GC.IGRadioVE;
    ImportToExistRadioPos = [ImportToExistRadioX, ImportToExistRadioY, ...
                             ImportToExistRadioW, ImportToExistRadioH];
    
    ImportToExistLabelX   = ImportToNewRadioX + GC.IGImportToRunNameHG;
    ImportToExistLabelY   = ImportToExistRadioY - GC.IGRadioVE ...
                            - GC.IGInputMarginMinorVE;
    ImportToExistLabelW   = GC.IGImportToRunNameHE;
    ImportToExistLabelH   = GC.IGTextVE;
    ImportToExistLabelPos = [ImportToExistLabelX, ImportToExistLabelY, ...
                             ImportToExistLabelW, ImportToExistLabelH];
    
    ImportToExistComboX   = ImportToExistLabelX + ImportToExistLabelW;
    ImportToExistComboY   = ImportToExistLabelY;
    ImportToExistComboW   = GC.IGImportToRunComboHE;
    ImportToExistComboH   = GC.IGComboVE;
    ImportToExistComboPos = [ImportToExistComboX, ImportToExistComboY, ...
                             ImportToExistComboW, ImportToExistComboH];

    RefreshButtonX   = ImportToLabelX;
    RefreshButtonY   = GC.IGWindowMarginVE + GC.IGOCHButtonVE ...
                       + GC.IGOCHButtonVG;
    RefreshButtonW   = GC.IGRSCButtonHE;
    RefreshButtonH   = GC.IGRSCButtonVE;
    RefreshButtonPos = [RefreshButtonX, RefreshButtonY, ...
                        RefreshButtonW, RefreshButtonH];
    
    SelectAllButtonX   = RefreshButtonX + GC.IGRSCButtonHE + GC.IGRSCButtonHG;
    SelectAllButtonY   = RefreshButtonY;
    SelectAllButtonW   = GC.IGRSCButtonHE;
    SelectAllButtonH   = GC.IGRSCButtonVE;
    SelectAllButtonPos = [SelectAllButtonX, SelectAllButtonY, ...
                          SelectAllButtonW, SelectAllButtonH];
    
    ClearAllButtonX   = SelectAllButtonX + GC.IGRSCButtonHE + GC.IGRSCButtonHG;
    ClearAllButtonY   = RefreshButtonY;
    ClearAllButtonW   = GC.IGRSCButtonHE;
    ClearAllButtonH   = GC.IGRSCButtonVE;
    ClearAllButtonPos = [ClearAllButtonX, ClearAllButtonY, ...
                         ClearAllButtonW, ClearAllButtonH];
    
    ImportVarsTableX   = ImportToLabelX;
    ImportVarsTableY   = RefreshButtonY + RefreshButtonH + GC.IGRSCButtonVG;
    ImportVarsTableW   = DialogW  - (2 * GC.IGWindowMarginHE);
    ImportVarsTableH   = ImportToExistComboY - ImportVarsTableY  ...
                         - GC.IGInputMarginMajorVE;
    ImportVarsTablePos = [ImportVarsTableX, ImportVarsTableY, ...
                          ImportVarsTableW, ImportVarsTableH];
    
    % Update positions - Common dialog
    set(this.OKButton,          'Position', OKButtonPos);
    set(this.CancelButton,      'Position', CancelButtonPos);
    set(this.HelpButton,        'Position', HelpButtonPos);
    
    % Update positions - Import from
    set(this.ImportFromLabel,              'Position', ImportFromLabelPos);
    set(this.ImportFromBaseRadio,          'Position', ImportFromBaseRadioPos);
    set(this.ImportFromMATRadio,           'Position', ImportFromMATRadioPos);
    set(this.ImportFromMATLabel,           'Position', ImportFromMATLabelPos);
    set(this.ImportFromMATEdit,            'Position', ImportFromMATEditPos);
    set(this.ImportFromMATButtonContainer, 'Position', ImportFromMATButtonPos);
    
    % Update positions - Import to
    set(this.ImportToLabel,      'Position', ImportToLabelPos);
    set(this.ImportToNewRadio,   'Position', ImportToNewRadioPos);
    set(this.ImportToExistRadio, 'Position', ImportToExistRadioPos);
    set(this.ImportToExistLabel, 'Position', ImportToExistLabelPos);
    set(this.ImportToExistCombo, 'Position', ImportToExistComboPos);
    
    % Update positions - Import variables
    set(this.ImportVarsTTContainer,    'Position', ImportVarsTablePos);
    set(this.RefreshButtonContainer,   'Position', RefreshButtonPos);
    set(this.SelectAllButtonContainer, 'Position', SelectAllButtonPos);
    set(this.ClearAllButtonContainer,  'Position', ClearAllButtonPos);
end