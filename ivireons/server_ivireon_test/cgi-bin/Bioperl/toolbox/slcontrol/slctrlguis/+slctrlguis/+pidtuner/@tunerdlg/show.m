function show(this)
% SHOW  used by the "Tune..." button callback function in the mask dialog
%
 
% Author(s): Rong Chen 26-May-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.10.4 $ $Date: 2010/03/26 17:54:06 $

% check if there is any unapplied change in the block dialog
if slctrlguis.pidtuner.utPIDhasUnappliedChanges(this.DataSrc.GCBH)
    ctrlMsgUtils.error('Slcontrol:pidtuner:tunerdlg_unappliedchanges');
end
% get current block parameters
[BlockType, BlockForm, BlockTimeDomain, BlockSampleTime, BlockIntMethod, BlockDerMethod, ...
    BlockP_Blk BlockI_Blk BlockD_Blk BlockN_Blk Blockb_Blk Blockc_Blk] ...
    = slctrlguis.pidtuner.utPIDgetBlockParameters(this.DataSrc.GCBH);
% if controller configuration changes, redesign
if ~strcmpi(BlockType,this.DataSrc.Type) || ...
        ~strcmpi(BlockForm,this.DataSrc.Form) || ...
        ~strcmpi(BlockTimeDomain,this.DataSrc.TimeDomain) || ...
        BlockSampleTime~=this.DataSrc.SampleTime || ...
        ~strcmpi(BlockIntMethod,this.DataSrc.IntMethod) || ...
        ~strcmpi(BlockDerMethod,this.DataSrc.DerMethod)
    % when block configuration changes, reset datasrc but do not
    % re-linearize the plant
    this.DataSrc.setConfiguration;
    this.DataSrc.setG2;
    this.DataSrc.setPIDTuningData;
    this.DataSrc.setBaseline;
    % reset plot panel
    str = [blanks(6) pidtool.utPIDgetStrings('cst','toolbar_formlabel') ': ' [upper(this.DataSrc.Form(1)) lower(this.DataSrc.Form(2:end))] ...
           blanks(6) pidtool.utPIDgetStrings('cst','toolbar_typelabel') ': ' upper(this.DataSrc.Type)];
    this.Handles.ControllerInfoLabel.setText(str);
    % reset design panel
    this.Handles.DesignPanelAdvanced.setPMVisible(~any(strcmpi(this.DataSrc.Type,{'p','i'})));
    % one-click design
    this.design(true);
    % set status text
    this.setStatusText(pidtool.utPIDgetStrings('scd','tunerdlg_newconfig_info'),'info');
    % reset GUI component
    this.initialize;
% if controller gains change, refresh block response
elseif BlockP_Blk~=this.DataSrc.P_Blk || ...
        BlockI_Blk~=this.DataSrc.I_Blk || ...
        BlockD_Blk~=this.DataSrc.D_Blk || ...
        BlockN_Blk~=this.DataSrc.N_Blk || ...
        Blockb_Blk~=this.DataSrc.b_Blk || ...
        Blockc_Blk~=this.DataSrc.c_Blk
    WeightChanged = (Blockb_Blk~=this.DataSrc.b_Blk) || (Blockc_Blk~=this.DataSrc.c_Blk);
    % reset PID gains for blocks and b and c for tuned
    this.DataSrc.setConfiguration;
    % reset block loop and GUI component
    this.DataSrc.setBaseline;
    s = this.DataSrc.generateBlockStructure;
    this.Handles.PlotPanel.setBaseController(s);
    % update tuned controller only if b and c are changed
    if WeightChanged
        % reset tuned loop and GUI component
        this.DataSrc.setTunedController;
        s = this.DataSrc.generateTunedStructure;
        this.Handles.PlotPanel.setTunedController(s);
    end
    % set status text
    this.setStatusText(pidtool.utPIDgetStrings('scd','tunerdlg_newgains_info'),'info');
    % if block controller becomes unstable, hide block response
    if this.DataSrc.getBlockStability
        this.Handles.PlotPanel.Handles.ShowBaseCheckBoxCOMPONENT.setSelected(true);
    else
        this.Handles.PlotPanel.Handles.ShowBaseCheckBoxCOMPONENT.setSelected(false);
        this.setStatusText(pidtool.utPIDgetStrings('scd','tunerdlg_unstableblock_warning'),'warning');
    end
    this.Handles.PlotPanel.showBaseResponse;
end
show@pidtool.AbstractTunerDlg(this);
