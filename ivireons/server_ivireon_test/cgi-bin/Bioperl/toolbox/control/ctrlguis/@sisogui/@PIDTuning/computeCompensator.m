function C = computeCompensator(this)

%   Author(s): R. Chen
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.14 $  $Date: 2010/05/10 16:59:05 $

% Disable all warnings
hw = ctrlMsgUtils.SuspendWarnings;  %#ok<NASGU>
% check if plant exists
C = [];
if ~isempty(this.OpenLoopPlant)
    % tuning method
    MethodIndex = awtinvoke(this.SpecPanelHandles.PIDComboBox,'getSelectedIndex()')+1;
    TuningMethod = this.TuningMethod(MethodIndex).Name;
    switch lower(TuningMethod)
        case 'fastdesign'
            % get controller type
            Index = this.utGetSelectedRadioButton(this.SpecPanelHandles.GroupTypeRRT);
            if Index<=3
                Type = this.ControllerTypesRRT{Index};
            else
                UseFilter = 2*double(awtinvoke(this.SpecPanelHandles.CheckboxRRT,'isSelected'));
                Type = this.ControllerTypesRRT{Index+UseFilter};
            end
            % check whether the selected controller type is supported by
            % the block based on the constraints
            if ~localCheckConstraints(Type,this.LoopData.C(this.IdxC).Constraints)
                msg = ctrlMsgUtils.message('Control:compDesignTask:strPIDNoHigherOrder');    
                this.utDisplayMessage('error',ltipack.utStripErrorHeader(msg));
                return
            end
            % get plant model (always assuming negative feedback)
            Model = -this.OpenLoopPlant;
            % create data src object
            DataSrc = pidtool.DataSrcLTI(Model,Type,[]);
            % design in two modes
            idx = this.SpecPanelHandles.OptionComboBox.getSelectedIndex;
            if idx==0
                % auto mode
                options = pidtuneOptions;
                DataSrc.oneclick(options.PhaseMargin);
            else
                % manual mode
                WC = this.DesignObjRRT.WC;
                PM = this.DesignObjRRT.PM;
                DataSrc.fastdesign(WC, PM);
            end
            C = DataSrc.C;
            IsStable = DataSrc.IsStable;
        otherwise
            % get controller type
            Index = this.utGetSelectedRadioButton(this.SpecPanelHandles.GroupTypeRule);
            Type = this.ControllerTypesRule{Index};
            % check whether the selected controller type is supported by
            % the block based on the constraints
            if ~localCheckConstraints(Type,this.LoopData.C(this.IdxC).Constraints)
                msg = ctrlMsgUtils.message('Control:compDesignTask:strPIDNoHigherOrder');    
                this.utDisplayMessage('error',ltipack.utStripErrorHeader(msg));
                return
            end
            % get plant model (always assuming negative feedback)
            Model = -this.OpenLoopPlant;
            % get formula
            Index = awtinvoke(this.SpecPanelHandles.ComboBoxRule,'getSelectedIndex')+1;
            Formula = this.Formula{Index};
            try
                C = utTuningPID(Model,Type,Formula);              
                if isempty(C)
                    IsStable = false;
                else
                    OLData = getPIDTuningData(Model*C,'p',0);
                    IsStable = OLData.checkCL([],[],OLData.LoopSign);
                end
            catch ME
                this.utDisplayMessage('error',ltipack.utStripErrorHeader(ME.message));
                return
            end
    end
    % check closed-loop stability
    if isempty(C) || ~IsStable
        msg = ctrlMsgUtils.message('Control:compDesignTask:TuningFailedToStabilize','PID');    
        this.utDisplayMessage('error',ltipack.utStripErrorHeader(msg));
        C = [];
    end
end
    
function OK = localCheckConstraints(Type,Constraints)
if isempty(Constraints)
    OK = true;
else
    MaxZeros = Constraints.MaxZeros;
    MaxPoles = Constraints.MaxPoles;
    switch Type 
        case 'p'
            OK = (MaxZeros >= 0) && (MaxPoles >= 0);
        case 'i'
            OK = (MaxZeros >= 0) && (MaxPoles >= 1);
        case 'pi'
            OK = (MaxZeros >= 1) && (MaxPoles >= 1);
        case 'pd'
            OK = (MaxZeros >= 1) && (MaxPoles >= 0);
        case 'pdf'
            OK = (MaxZeros >= 1) && (MaxPoles >= 1);
        case 'pid'
            OK = (MaxZeros >= 2) && (MaxPoles >= 1);
        case 'pidf'
            OK = (MaxZeros >= 2) && (MaxPoles >= 2);
    end
end