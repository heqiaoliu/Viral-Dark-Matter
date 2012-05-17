function createUIControls_CompareSignalsTab(this)

    % Copyright 2010 The MathWorks, Inc.
    
    % cache geometric constants
    GC = Simulink.sdi.GeoConst;
   
    % set visibility
    this.runVisibleCompSig = false;
    this.blockSrcVisibleCompSig = true;
    this.colorVisibleCompSig = true;
    this.absTolVisibleCompSig = false;
    this.relTolVisibleCompSig = false;
    this.syncVisibleCompSig = false;
    this.interpVisibleCompSig = false;
    this.dataSourceVisibleCompSig = false;
    this.modelSourceVisibleCompSig = false;
    this.signalLabelVisibleCompSig = true;
    this.rootVisibleCompSig = false;
    this.timeVisibleCompSig = false;
    this.portVisibleCompSig = false;
    this.dimVisibleCompSig = false;
    this.channelVisibleCompSig = false;
    
    this.createUIControls_ContextMenuTableHeaderCompSig();
    
    this.compareSigVertSplitter = Simulink.sdi.splitPane(this.TabCompareSignals,...
                                                         'hori',                ...
                                                          6,                    ...
                                                         [0.5 0.5 0.5],         ...
                                                         0.5,                   ...
                                                         [],                    ...
                                                         GC.mOptionWidth + GC.mOptionHeight);

    this.compareSignalsTT = this.createTreeTable(this.compareSigVertSplitter.leftUpPane,...
                                                 this.commonTableModel);
    set(this.compareSignalsTT.container,'parent',...
        this.compareSigVertSplitter.leftUpPane);
    set(this.compareSigVertSplitter.leftUpPane,'resizefcn',...
        @this.positionControl_CompareSignalsLeftPane);
   
    set(this.compareSigVertSplitter.rightDownPane,'resizefcn',...
        @this.positionControl_CompareSignalsRightPane);
    p = getpixelposition(this.compareSigVertSplitter.leftUpPane);    
    setpixelposition(this.compareSignalsTT.container,...
                     [p(1)+20 p(2)+50 p(3)-50 p(4)-70]);
    
    % order in which controls are created is important for visual ordering
    this.compareSigVertSplitter.addDivider();
    this.compareSigVertSplitter.addCallbackLeft(@this.positionControls_OptionsButton);
    this.compareSigVertSplitter.addCallbackRight(@this.positionControls_OptionsButton);

      
    this.compareSigHorSplitter = Simulink.sdi.splitPane(this.compareSigVertSplitter.rightDownPane,...
                                                        'vert',                                   ...
                                                        6,                                        ...
                                                        [0.5 0.5 0.5],                            ...
                                                        0.5,                                      ...
                                                        GC.mOptionHeight,                         ...
                                                        GC.mOptionHeight);
    % create axes
    this.AxesCompareSignalsData = axes('Parent',                    ...
                                       this.compareSigHorSplitter.rightDownPane);
    this.AxesCompareSignalsDiff = axes('Parent',                    ...
                                       this.compareSigHorSplitter.leftUpPane);

      
    % Axes titles and labels
    title(this.AxesCompareSignalsData, this.sd.mgSignals);
    title(this.AxesCompareSignalsDiff, this.sd.mgDifference);
    
    % link axes
    linkaxes([this.AxesCompareSignalsData this.AxesCompareSignalsDiff], 'x');
    
    set(this.compareSigHorSplitter.rightDownPane,'resizefcn',...
        @this.positionControl_CompareSignalsRightPane);
    set(this.compareSigHorSplitter.leftUpPane,'resizefcn',...
        @this.positionControl_CompareSignalsRightPane);

    this.compareSigHorSplitter.addCallbackLeft(@this.positionControls_OptionsButton);
    this.compareSigHorSplitter.addCallbackRight(@this.positionControls_OptionsButton);
end