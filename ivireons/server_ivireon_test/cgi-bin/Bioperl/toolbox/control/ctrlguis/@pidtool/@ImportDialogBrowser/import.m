function import(this)
%IMPORT 

%   Author(s): R. Chen
%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/05/10 16:58:55 $

% get target, get selected, update @design object
targetIndex = this.Handles.ComboBox.getSelectedIndex;
modelIndex = this.Handles.Table.getSelectedRow + 1; %java to matlab indexing
if modelIndex == 0 
    return
else
    this.Handles.ImportButton.setEnabled(false);
    this.Handles.CloseButton.setEnabled(false);
    sys = this.VarData{modelIndex};
    if targetIndex==0
        % deal with plant model
        switch class(sys);
            case {'idarx','idgrey','idss'}
                sys = ss(subsref(sys,struct('type','()','subs',{{'m'}})));
            case {'idpoly','idproc'}
                sys = zpk(subsref(sys,struct('type','()','subs',{{'m'}})));
            case 'idfrd'
                sys = frd(sys);
        end
        % import as sys
        convertFRD = false;
        if isa(sys,'ss') && hasInternalDelay(sys)
            try
                zpk(sys);
            catch %#ok<CTCH>
                convertFRD = true;
            end
        end
        if convertFRD || isa(sys,'frd')
            NUP = str2double(this.Handles.NUPTextField.getText);
        else
            NUP = 0;
        end
        this.Tuner.DataSrc.setG(sys,NUP);
        % reset PIDTuningData
        this.Tuner.DataSrc.setPIDTuningData;
        % one-click design
        this.Tuner.design;
        % reset GUI component
        this.Tuner.initialize;
        % set status text
        this.Tuner.setStatusText(pidtool.utPIDgetStrings('cst','tunerdlg_plantchanged_info'),'info');
    else
        % deal with baseline
        if isa(sys,'frd') || isa(sys,'idmodel') || isa(sys,'idfrd')
            this.Tuner.setStatusText(pidtool.utPIDgetStrings('cst','wrongbaseline'),'warning');
            this.Handles.ImportButton.setEnabled(true);
            this.Handles.CloseButton.setEnabled(true);
            return
        end
        % pre-process Ts
        if sys.Ts ~= this.Tuner.DataSrc.Ts
            this.Tuner.setStatusText(ctrlMsgUtils.message('Control:pidtool:wrongbaselinets',num2str(this.Tuner.DataSrc.Ts)),'warning');
            this.Handles.ImportButton.setEnabled(true);
            this.Handles.CloseButton.setEnabled(true);
            return
        end
        % enable 
        this.Tuner.Handles.PlotPanel.Handles.ShowBaseCheckBoxCOMPONENT.setSelected(true);
        this.Tuner.Handles.PlotPanel.Handles.ShowBaseCheckBoxCOMPONENT.setEnabled(true);
        % import as Baseline
        this.Tuner.DataSrc.setBaseline(sys);
        % update GUI
        s = this.Tuner.DataSrc.generateBaseStructure;
        this.Tuner.Handles.PlotPanel.setBaseController(s);
        % if base controller results in unstable or improper closed loop (an empty
        % @ss), hide base response
        if isempty(this.Tuner.DataSrc.r2y_Base)
            this.Tuner.Handles.PlotPanel.Handles.ShowBaseCheckBoxCOMPONENT.setSelected(false);
            this.Tuner.setStatusText(pidtool.utPIDgetStrings('cst','tunerdlg_improperbase_warning'),'warning');
        elseif ~this.Tuner.DataSrc.IsStable_Base
            this.Tuner.Handles.PlotPanel.Handles.ShowBaseCheckBoxCOMPONENT.setSelected(false);
            this.Tuner.setStatusText(pidtool.utPIDgetStrings('cst','tunerdlg_unstablebase_warning'),'warning');
        else
            this.Tuner.setStatusText(pidtool.utPIDgetStrings('cst','tunerdlg_baselinechanged_info'),'info');
        end
        this.Tuner.Handles.PlotPanel.showBaseResponse;
    end
    this.Handles.ImportButton.setEnabled(true);
    this.Handles.CloseButton.setEnabled(true);
end



