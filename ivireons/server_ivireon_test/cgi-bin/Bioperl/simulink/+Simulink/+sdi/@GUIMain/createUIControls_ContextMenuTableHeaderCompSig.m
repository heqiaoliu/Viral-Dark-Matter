function createUIControls_ContextMenuTableHeaderCompSig(this)

    % Copyright 2010 The MathWorks, Inc.

    this.tableColumnSelectContextMenuCompareSig = uicontextmenu...
                                                 ('parent', this.HDialog);
                                             
    this.contextMenuColumnsCompSig = uimenu(this.tableColumnSelectContextMenuCompareSig,...
                                           'label', this.sd.mgColumns);
                                      
    this.contextMenuSortByCompSig =    uimenu                                       ...
                                      (this.tableColumnSelectContextMenuCompareSig,...
                                      'label', this.sd.sortBy);
    
    this.contextMenuSortByRunCompSig =                                    ...
                                      uimenu                              ...
                                     (this.contextMenuSortByCompSig,      ...
                                     'label', this.sd.mgRun,              ...
                                     'callback',                          ...
                                     {@this.tableContextMenuCallback_Sort,...
                                     'GRUNNAME'});
                                 
    set(this.contextMenuSortByRunCompSig, 'Checked', 'on');                                 
    this.contextMenuSortByBlockCompSig =  uimenu                              ...
                                     (this.contextMenuSortByCompSig,          ...
                                     'label', this.sd.IGBlockSourceColName,   ...
                                     'callback',                              ...
                                     {@this.tableContextMenuCallback_Sort,    ...
                                     'GBLOCKPATH'});         
    this.contextMenuSortByDataCompSig =     uimenu                            ...
                                     (this.contextMenuSortByCompSig,          ...
                                     'label', this.sd.IGDataSourceColName,    ...
                                     'callback',                              ...
                                     {@this.tableContextMenuCallback_Sort,    ...
                                     'GDATASOURCE'});  
    this.contextMenuSortByModelCompSig =     uimenu                           ...
                                     (this.contextMenuSortByCompSig,          ...
                                     'label', this.sd.IGModelSourceColName,   ...
                                     'callback',                              ...
                                     {@this.tableContextMenuCallback_Sort,    ...
                                     'GMODEL'});
    this.contextMenuSortBySignalNameCompSig =  uimenu                         ...
                                     (this.contextMenuSortByCompSig,          ...
                                     'label', this.sd.mgSigLabel,             ...
                                     'callback',                              ...
                                     {@this.tableContextMenuCallback_Sort,    ...
                                     'GSIGNALNAME'});                                                                            
                                  
    this.contextMenuRunCompSig  = uimenu                   ...
                                  (this.contextMenuColumnsCompSig,...
                                  'label', this.sd.mgRun);
    this.contextMenuColorCompSig  = uimenu                  ...
                                   (this.contextMenuColumnsCompSig,...
                                   'label', this.sd.mgLine);
    this.contextMenuAbsTolCompSig  = uimenu                   ...
                                     (this.contextMenuColumnsCompSig,...
                                     'label',                 ...
                                     this.sd.MGAbsTolLbl);
    this.contextMenuRelTolCompSig  = uimenu                   ...
                                     (this.contextMenuColumnsCompSig,...
                                     'label',                 ...
                                     this.sd.MGRelTolLbl);                                 
    this.contextMenuSyncCompSig  = uimenu                   ...
                                   (this.contextMenuColumnsCompSig,...
                                   'label',                 ...
                                   this.sd.MGSynchMethodLbl);                                        
    this.contextMenuInterpCompSig  = uimenu                 ...
                                   (this.contextMenuColumnsCompSig,...
                                   'label',                 ...
                                   this.sd.MGInterpMethodLbl);                                 
                                    
        
    this.contextMenuDataSourceCompSig  = uimenu                  ...
                                        (this.contextMenuColumnsCompSig,...
                                         'label',                ...
                                         this.sd.IGDataSourceColName);
    this.contextMenuModelSourceCompSig = uimenu                  ...
                                        (this.contextMenuColumnsCompSig,...
                                        'label', this.sd.IGModelSourceColName);
    this.contextMenuSignalLabelCompSig = uimenu                  ...
                                        (this.contextMenuColumnsCompSig,...
                                        'label', this.sd.mgSigLabel);
    this.contextMenuRootCompSig = uimenu                  ...
                                 (this.contextMenuColumnsCompSig,...
                                 'label', this.sd.IGRootSourceColName);                                   
    this.contextMenuTimeSourceCompSig = uimenu                  ...
                                       (this.contextMenuColumnsCompSig,...
                                        'label', this.sd.IGTimeSourceColName);                                     
    this.contextMenuPortCompSig = uimenu                   ...
                                  (this.contextMenuColumnsCompSig,...
                                  'label', this.sd.IGPortIndexColName);   
    this.contextMenuDimCompSig = uimenu                  ...
                                (this.contextMenuColumnsCompSig,...
                                'label', this.sd.mgDimensions);  
    this.contextMenuChannelCompSig = uimenu                   ...
                                     (this.contextMenuColumnsCompSig,...
                                     'label', this.sd.mgChannel); 
                                                                
    set(this.contextMenuRunCompSig, 'callback',...
        @this.tableContextMenu_CompareSignals);
    set(this.contextMenuColorCompSig, 'callback',...
        @this.tableContextMenu_CompareSignals);
    set(this.contextMenuAbsTolCompSig, 'callback',...
        @this.tableContextMenu_CompareSignals);
    set(this.contextMenuRelTolCompSig, 'callback',...
        @this.tableContextMenu_CompareSignals);
    set(this.contextMenuSyncCompSig, 'callback',...
        @this.tableContextMenu_CompareSignals);
    set(this.contextMenuInterpCompSig, 'callback',...
        @this.tableContextMenu_CompareSignals);    
    set(this.contextMenuDataSourceCompSig, 'callback',...
        @this.tableContextMenu_CompareSignals);
    set(this.contextMenuModelSourceCompSig, 'callback',...
        @this.tableContextMenu_CompareSignals);
    set(this.contextMenuSignalLabelCompSig, 'callback',...
        @this.tableContextMenu_CompareSignals);
    set(this.contextMenuRootCompSig, 'callback',...
        @this.tableContextMenu_CompareSignals);
    set(this.contextMenuTimeSourceCompSig, 'callback',...
        @this.tableContextMenu_CompareSignals);
    set(this.contextMenuPortCompSig, 'callback',...
        @this.tableContextMenu_CompareSignals);
    set(this.contextMenuDimCompSig, 'callback',...
        @this.tableContextMenu_CompareSignals);
    set(this.contextMenuChannelCompSig, 'callback',...
        @this.tableContextMenu_CompareSignals);    
end

