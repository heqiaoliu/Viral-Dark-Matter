classdef DataSrcLTI < handle
    % DATASRCLTI subclass
    %
    
    % Author(s): R. Chen
    % Copyright 2009-2010 The MathWorks, Inc.
    % $Revision: 1.1.8.10 $ $Date: 2010/05/10 16:58:43 $
    
    properties
        
        % Plant and disturbance model: G
        G;              
        NUP;            % number of unstable poles used in @frd
        
        % PIDTuningData
        PIDTuningData;
         
        % PID Configuration
        Ts              % same as G.Ts
        Type;           % valid types: p, i, pi, pd, pid, pdf, pidf
        Form;           % valid forms: parallel, standard
        IFormula;       % valid methods: forward euler, backward euler, trapezoidal
        DFormula;       % valid methods: forward euler, backward euler, trapezoidal
        
        % Loop Information from tuner
        C;              % designed PID object
        OLsys;          % G*C
        r2y;            % feedback(G*C,1)
        r2u;            % feedback(C,G)
        id2y;           % feedback(G,C)
        od2y;           % feedback(1,G*C)
        IsStable;       % closed loop stability of r2y

        % Loop Information from baseline
        C_Base;
        OLsys_Base;
        r2y_Base;
        r2u_Base;
        id2y_Base;
        od2y_Base;
        IsStable_Base;
        
    end
    
    methods(Access = 'public')
        
        % constructor
        function this = DataSrcLTI(G,Type,Baseline)
            this.setG(G,0);
            this.setConfiguration(Type,Baseline);
            this.setPIDTuningData;
            this.setBaseline(Baseline);
        end
        
        function setG(this,G,NUP)
            this.G = G;
            this.Ts = getTs(G);
            this.NUP = NUP;
        end
        
        function setConfiguration(this,Type,Baseline)
            if isa(Baseline,'pid') || isa(Baseline,'pidstd')
                % baseline is PID controller, obtain controller configuration
                this.setConfigurationFromC(Baseline);
            else
                % otherwise, obtain default PI configuration
                PID = ltipack.getPIDfromType(Type,this.Ts);
                this.setConfigurationFromC(PID);
            end
        end
        
        function setPIDTuningData(this)
            PID = ltipack.getPIDfromType(this.Type,this.Ts,this.Form);
            PID.IFormula = this.IFormula;
            PID.DFormula = this.DFormula;
            this.PIDTuningData = getPIDTuningData(this.G,PID,this.NUP);
        end
        
        function setConfigurationFromC(this,C)
            this.Type = lower(getType(C));
            if isa(C,'pid')
                this.Form = 'parallel';
            else
                this.Form = 'standard';
            end
            this.IFormula = C.IFormula;
            this.DFormula = C.DFormula;
        end
        
        function setBaseline(this, C)
            if ischar(C)
                % there is no baseline controller to compare with
                this.C_Base = [];
            else
                % baseline controller is C
                if ~isempty(C)
                    try %#ok<*TRYNC>
                        if strcmp(this.Form,'parallel')
                            C = pid(C);
                        else
                            C = pidstd(C);
                        end
                    end
                    this.C_Base = C;
                    [this.OLsys_Base this.r2y_Base this.r2u_Base this.id2y_Base this.od2y_Base] = ...
                        pidtool.utPIDgetLoopfromC(this.C_Base,this.G);
                    this.IsStable_Base = this.getBaseStability;
                end
            end
        end
        
        % compute PID based on PM
        function WC = oneclick(this, PM)
            % one click design based on PM
            [PIDdata, info] = tune(this.PIDTuningData,pidtuneOptions('PhaseMargin',PM));
            if strcmp(this.Form,'parallel')
                PID = pid.make(PIDdata);
            else
                PID = pidstd.make(PIDdata);
            end
            this.C = PID;
            this.IsStable = info.Stable;
            WC = info.wc;
            [this.OLsys this.r2y this.r2u this.id2y this.od2y] = ...
                pidtool.utPIDgetLoopfromC(this.C,this.G);
        end
        
        % compute PID based on WC and PM
        function OK = fastdesign(this, WC, PM)
            % interactive design based on WC and PM
            try
                [PIDdata, info] = tune(this.PIDTuningData,...
                    pidtuneOptions('PhaseMargin',PM,'CrossoverFrequency',WC));
                OK = true;
            catch %#ok<CTCH>
                OK = false;
                return
            end
            if strcmp(this.Form,'parallel')
                PID = pid.make(PIDdata);
            else
                PID = pidstd.make(PIDdata);
            end
            this.C = PID;
            this.IsStable = info.Stable;
            [this.OLsys this.r2y this.r2u this.id2y this.od2y] = ...
                pidtool.utPIDgetLoopfromC(this.C,this.G);
        end

        % convert meta information into a structure for GUI display
        function s = generateTunedStructure(this)
            if strcmp(this.Form,'parallel')
                [P I D N] = piddata(this.C);
            else
                [P I D N] = pidstddata(this.C);
            end
            s = struct( 'Type', this.Type, ...
                        'Form', this.Form, ...
                        'P',P,...
                        'I',I,...
                        'D',D,...
                        'N',N,...
                        'b',[],...
                        'c',[],...
                        'OLsys',this.OLsys,...
                        'r2y',this.r2y,...
                        'r2u',this.r2u,...
                        'id2y',this.id2y,...
                        'od2y',this.od2y,...
                        'Plant',this.G,...
                        'IsStable',this.IsStable);
        end
        
        function s = generateBaseStructure(this)
            if isa(this.C_Base,'pid') && strcmp(this.Form,'parallel') 
                [P I D N] = piddata(this.C_Base);
                type = lower(getType(this.C_Base));
            elseif isa(this.C_Base,'pidstd') && strcmp(this.Form,'standard')
                [P I D N] = pidstddata(this.C_Base);
                type = lower(getType(this.C_Base));
            else
                P = []; I = []; D = []; N = [];
                type = this.Type;
            end
            s = struct( 'Type', type, ...
                        'Form', this.Form, ...
                        'P',P,...
                        'I',I,...
                        'D',D,...
                        'N',N,...
                        'b',[],...
                        'c',[],...
                        'OLsys',this.OLsys_Base,...
                        'r2y',this.r2y_Base,...
                        'r2u',this.r2u_Base,...
                        'id2y',this.id2y_Base,...
                        'od2y',this.od2y_Base,...
                        'Plant',this.G,...
                        'IsStable',this.IsStable_Base);
        end
        
        % helper function used by plot panel
        function Data = initialParameterTableData(this)
            Data = cell(4,3);
            Data(:)={blanks(4)};
            if strcmp(this.Form,'parallel');
                Data(1,1) = {'Kp'};
                Data(2,1) = {'Ki'};
                Data(3,1) = {'Kd'};
                Data(4,1) = {'Tf'};
            else
                Data(1,1) = {'Kp'};
                Data(2,1) = {'Ti'};
                Data(3,1) = {'Td'};
                Data(4,1) = {'N'};
            end
        end
        
        function isStable = getBaseStability(this)
            OLData = getPIDTuningData(this.G*this.C_Base,'p',this.NUP);
            isStable = OLData.checkCL([],[],OLData.LoopSign);
        end

    end
    
    
end

