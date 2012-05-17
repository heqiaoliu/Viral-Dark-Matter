function setCallbacks_CompareSignals(this)
    
    % Copyright 2009-2010 The MathWorks, Inc.
    tableHeader = this.compareSignalsTT.TT.getTableHeader();
    tableHeader = handle(tableHeader, 'callbackproperties');
    set(tableHeader, 'MouseClickedCallback',              ...
        {@this.tableHeaderContextMenuClick_CompareSignals,...
        this.compareSignalsTT});
    this.compareSignalsTT.TableCallback.MouseClickedCallback = ...
        {@this.tableMouseClickedCallback_CompareSignals};
    
    hCompareSignalsTT = handle(this.compareSignalsTT.TT, 'callbackproperties');
    set(hCompareSignalsTT, 'KeyPressedCallback', @this.dialogKeyPress);
    % Color cell editor
    this.hColorEditorCompSig = handle(this.colorEditorCompSig,...
                                      'callbackproperties');
    this.hColorEditorCompSig.EditingStoppedCallback =...
                                        {@(s,e)this.updateColorPlotCompareSig};
                                    
    % Editing stopper callbacks for left and right check boxes
    hCheckBoxLeft = handle(this.checkboxCellEditorLeftCompSig,...
                           'callbackproperties');
    hCheckBoxRight = handle(this.checkboxCellEditorRightCompSig,...
                           'callbackproperties');
    hCheckBoxLeft.EditingStoppedCallback = {@this.callback_CheckBoxCompSig};
    hCheckBoxRight.EditingStoppedCallback = {@this.callback_CheckBoxCompSig};
end


