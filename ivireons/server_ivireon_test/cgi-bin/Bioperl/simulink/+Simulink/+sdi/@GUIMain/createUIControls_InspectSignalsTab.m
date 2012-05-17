function createUIControls_InspectSignalsTab(this)

    % Copyright 2010 The MathWorks, Inc.
    
    % Inspec signal Axes   
    this.AxesInspectSignals     = axes('Parent',this.inspectSplitter.rightDownPane,...
                                       'Units', 'pixels');
    
    this.HInspectPlot.HAxes = this.AxesInspectSignals;        
    
    
    % **************************************
    % **** Inspect Signals - Tree Table ****
    % **************************************   
   
    this.createUIControls_commonTTModel();
    this.InspectTT = this.createTreeTable(this.inspectSplitter.leftUpPane,...
                                          this.commonTableModel, 'param');
    set(this.InspectTT.container,'parent',this.inspectSplitter.leftUpPane);
    set(this.inspectSplitter.leftUpPane,'resizefcn',...
        @this.positionControl_InspectSignalsLeftPane)
    set(this.inspectSplitter.rightDownPane,'resizefcn',...
        @this.positionControl_InspectSignalsRightPane);
    this.inspectSplitter.addDivider();

    this.inspectSplitter.addCallbackRight(@this.positionControls_OptionsButton);
    this.inspectSplitter.addCallbackLeft(@this.positionControls_OptionsButton);

    %     %search panel
    %     this.inspectSearchPanel = javaObjectEDT('javax.swing.JPanel');
    %     this.inspectSearch= javaObjectEDT('com.jidesoft.swing.TableSearchable', this.InspectTT.TT);
    %     this.inspectSearch.setSearchColumnIndices([0,1,2,3,4,5,6,7]);
    %     this.inspectSearch.setFromStart(false);
    %     this.inspectSearchPanel.add(javaObjectEDT('com.jidesoft.swing.SearchableBar', this.inspectSearch));
    %     this.InspectTT.TT.setColumnSelectionAllowed(true);
    %     this.InspectTT.TT.setRowSelectionAllowed(true);
    %     % javaObjectEDT('com.mathworks.toolbox.sdi.sdi.SdiSearchableBar', oop, this.InspectTT.TT);
    %     [~, this.inspectSearchContainer] = javacomponent(this.inspectSearchPanel, [100 3 700 50], this.HDialog);
    
    % create common context menu
    this.createUIControls_tableContextMenu();
    
    % Hide or show columns
    this.runVisibleInsp = false;
    this.blockSrcVisibleInsp = true;
    this.plotVisibleInsp = true;
    this.colorVisibleInsp = true;
    this.absTolVisibleInsp = false;
    this.relTolVisibleInsp = false;
    this.syncVisibleInsp = false;
    this.interpVisibleInsp = false;
    this.dataSourceVisibleInsp = false;
    this.modelSourceVisibleInsp = false;
    this.signalLabelVisibleInsp = true;
    this.rootVisibleInsp = false;
    this.timeVisibleInsp = false;
    this.portVisibleInsp = false;
    this.dimVisibleInsp = false;
    this.channelVisibleInsp = false;
    
    % create context menu for treetable
    this.createUIControls_ContextMenuTableHeaderInspect(); 
   
 