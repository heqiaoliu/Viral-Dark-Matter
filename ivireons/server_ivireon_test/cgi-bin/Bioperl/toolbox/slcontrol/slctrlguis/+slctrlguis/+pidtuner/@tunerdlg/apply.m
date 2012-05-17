function apply(this)
%APPLY  apply current design to PID block

% Author(s): R. Chen
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.8 $ $Date: 2010/04/11 20:41:12 $

if ishandle(this.DataSrc.GCBH)
    % check if there is any unapplied change in the block dialog
    [HasUnappliedChanges hDialog] = slctrlguis.pidtuner.utPIDhasUnappliedChanges(this.DataSrc.GCBH);    
    % check if controller configuration is changed since tuner launched
    [BlockType, BlockForm, BlockTimeDomain, BlockSampleTime, BlockIntMethod, BlockDerMethod] ...
        = slctrlguis.pidtuner.utPIDgetBlockParameters(this.DataSrc.GCBH);
    if ~strcmpi(BlockType,this.DataSrc.Type) || ...
            ~strcmpi(BlockForm,this.DataSrc.Form) || ...
            ~strcmpi(BlockTimeDomain,this.DataSrc.TimeDomain) || ...
            (strcmpi(this.DataSrc.TimeDomain,'discrete-time') && (BlockSampleTime~=this.DataSrc.SampleTime || ...
            ~strcmpi(BlockIntMethod,this.DataSrc.IntMethod) || ...
            ~strcmpi(BlockDerMethod,this.DataSrc.DerMethod)))
        question0 = pidtool.utPIDgetStrings('scd','tunerdlg_mask_question0');
        question1 = pidtool.utPIDgetStrings('scd','tunerdlg_mask_question1');
        question2 = pidtool.utPIDgetStrings('scd','tunerdlg_mask_question2');
        question3 = pidtool.utPIDgetStrings('scd','tunerdlg_mask_question3');
        question4 = pidtool.utPIDgetStrings('scd','tunerdlg_mask_question4');
        question5 = pidtool.utPIDgetStrings('scd','tunerdlg_mask_question5');
        question6 = pidtool.utPIDgetStrings('scd','tunerdlg_mask_question6');
        question7 = pidtool.utPIDgetStrings('scd','tunerdlg_mask_question7');
        question8 = pidtool.utPIDgetStrings('scd','tunerdlg_mask_question8');
        question9 = pidtool.utPIDgetStrings('scd','tunerdlg_mask_question9');
        question10 = pidtool.utPIDgetStrings('scd','tunerdlg_mask_question10');
        titlestr = pidtool.utPIDgetStrings('scd','tunerdlg_mask_title');
        uiwait(errordlg(sprintf('%s\n\n%s\n\n%s\n%s\n%s\n%s\n%s\n%s\n\n%s\n\n%s\n%s\n%s\n%s\n%s\n%s\n\n%s\n\n%s',...
            question0,...
            question1,...
            [question5 ' ',strrep(this.DataSrc.Type,'f','')],...
            [question6 ' ',this.DataSrc.Form],...
            [question7 ' ',this.DataSrc.TimeDomain],...
            [question8 ' ',num2str(this.DataSrc.SampleTime)],...
            [question9 ' ',this.DataSrc.IntMethod],...
            [question10 ' ',this.DataSrc.DerMethod],...
            question2,...
            [question5 ' ',strrep(BlockType,'f','')],...
            [question6 ' ',BlockForm],...
            [question7 ' ',BlockTimeDomain],...
            [question8 ' ',num2str(BlockSampleTime)],...
            [question9 ' ',BlockIntMethod],...
            [question10 ' ',BlockDerMethod],...
            question3,...
            question4),titlestr,'modal'));
        return
    end
    % reset block parameter, metrics and plot with new controller 
    this.DataSrc.resetBlockParameters;
    s = this.DataSrc.generateBlockStructure;
    this.Handles.PlotPanel.setBaseController(s);
    % set block parameters
    switch lower(this.DataSrc.Type)
        case 'p'
            params = {'P'}; strVal = {mat2str(this.DataSrc.P)};
        case 'i'
            params = {'I'}; strVal = {mat2str(this.DataSrc.I)};
        case 'pi'
            params = {'P','I'}; strVal = {mat2str(this.DataSrc.P),mat2str(this.DataSrc.I)};
        case 'pdf'
            params = {'P','D','N'}; strVal = {mat2str(this.DataSrc.P),mat2str(this.DataSrc.D),mat2str(this.DataSrc.N)};                
        case 'pidf'
            params = {'P','I','D','N'}; strVal = {mat2str(this.DataSrc.P),mat2str(this.DataSrc.I),mat2str(this.DataSrc.D),mat2str(this.DataSrc.N)};                
    end
    slctrlguis.updateBlockParameter(this.DataSrc.GCBH,params,strVal);
    % if there is no unapplied changes in the block, commit
    if HasUnappliedChanges
        this.setStatusText(pidtool.utPIDgetStrings('scd','tunerdlg_apply_warning'),'warning');
    else
        % only apply when mask dialog is open
        if ~isempty(hDialog)
            hDialog.apply;
            this.setStatusText('');
        end
    end
end

