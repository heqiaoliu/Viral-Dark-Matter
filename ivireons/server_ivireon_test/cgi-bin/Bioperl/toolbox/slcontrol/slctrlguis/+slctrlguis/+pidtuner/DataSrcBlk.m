classdef DataSrcBlk < handle
    % DATASRCBLK subclass
    %
    
    % Author(s): R. Chen
    % Copyright 2009-2010 The MathWorks, Inc.
    % $Revision: 1.1.8.12 $ $Date: 2010/05/10 17:57:44 $
 
    properties
        
        % Block handle
        GCBH;
        
        % Plant
        G1;             % original plant
        G2;             % plant used in design

        % PIDTuningData
        PIDTuningData;
        
        % Controller Configuration
        DOF             % 1 or 2
        Type;           % valid types: p, i, pi, pd, pid, pdf, pidf
        Form;           % valid forms: parallel, ideal
        TimeDomain;     % valid domains: continuous-time, discrete-time
        SampleTime;     % valid Ts: any non-negative, finite, real number
        IntMethod;      % valid methods: forward euler, backward euler, trapezoidal
        DerMethod;      % valid methods: forward euler, backward euler, trapezoidal
        
        % Controller Parameters from tuner
        P;
        I;
        D;
        N;
        b;
        c;
        % Controller Parameters from block
        P_Blk;
        I_Blk;
        D_Blk;
        N_Blk;
        b_Blk;
        c_Blk;

        % Loop Information from tuner
        Cfb;                    % 1dof or feedback part of 2dof
        Cff;                    % feed-forward part of 2dof
        OLsys;                  % G*Cfb
        r2y;                    % 1dof: G*Cfb/(1+G*Cfb); 2dof: G*(Cff+Cfb)/(1+G*Cfb)
        r2u;                    % 1dof: Cfb/(1+G*Cfb); 2dof: (Cff+Cfb)/(1+G*Cfb)
        id2y;                   % 1dof: G/(1+G*Cfb); 2dof: same
        od2y;                   % 1dof: 1/(1+G*Cfb); 2dof: same
        IsStable                % closed loop stability

        % Loop Information from block
        Cfb_Blk;
        Cff_Blk;
        OLsys_Blk;
        r2y_Blk;
        r2u_Blk;
        id2y_Blk;
        od2y_Blk;
        IsStable_Blk;

    end
    
    methods(Access = 'public')

        % Constructor
        function this = DataSrcBlk(GCBH,G)
            this.b = 1;
            this.c = 1;
            this.GCBH = GCBH;
            this.DOF = 1;
            this.setG1(G);
            this.setConfiguration;
            this.setG2;
            this.setPIDTuningData;
            this.setBaseline;
        end
        
        function setG1(this,G)
            this.G1 = G;
        end
        
        function setConfiguration(this)
            [this.Type, this.Form, this.TimeDomain, this.SampleTime, this.IntMethod, this.DerMethod, ...
                this.P_Blk this.I_Blk this.D_Blk this.N_Blk this.b_Blk this.c_Blk] ...
                = slctrlguis.pidtuner.utPIDgetBlockParameters(this.GCBH);
            this.b = this.b_Blk;
            this.c = this.c_Blk;
        end
        
        function setG2(this)
            % rate conversion: 
            % if G1 is CT and C is CT, G2 = G1
            % if G1 is DT and C is CT, G2 = d2c(G1,'tustin')
            % if G1 is CT and C is DT, G2 = c2d(G1,C.Ts,'tustin')
            % if G1 is DT and C is DT, G2 = d2d(G1,C.Ts,'tustin')
            if this.G1.Ts==0
                this.G2 = slctrlguis.pidtuner.utPIDconvert(this.G1,'continuous-time',this.TimeDomain,this.SampleTime);
            else
                this.G2 = slctrlguis.pidtuner.utPIDconvert(this.G1,'discrete-time',this.TimeDomain,this.SampleTime);
            end
            this.G2.InputName = 'u';
            this.G2.OutputName = 'y';
        end
        
        function setPIDTuningData(this)
            PID = ltipack.getPIDfromType(this.Type,this.G2.Ts);
            if this.G2.Ts>0
                PID.IFormula = this.IntMethod(1);
                PID.DFormula = this.DerMethod(1);
            end
            this.PIDTuningData = getPIDTuningData(this.G2,PID,0);
        end
        
        % update PID and loop data based on PID gains from block
        function setBaseline(this)
            [~,~,this.Cfb_Blk] = utPID1dof_getCfreeCfixedfromPIDN(this.P_Blk,this.I_Blk,this.D_Blk,this.N_Blk,this.SampleTime,this.getCtrlStruct);
            this.Cfb_Blk.InputName = 'e';  
            this.Cfb_Blk.OutputName = 'ufb';
            [this.OLsys_Blk this.r2y_Blk this.r2u_Blk this.id2y_Blk this.od2y_Blk] = ...
                pidtool.utPIDgetLoopfromC(this.Cfb_Blk,this.G2);
            this.IsStable_Blk = this.getBlockStability;
        end
        
        % compute PID based on PM
        function WC = oneclick(this, PM)
            % one click design based on PM
            [Cdata, info] = tune(this.PIDTuningData,pidtuneOptions('PhaseMargin',PM),false);
            C = zpk.make(Cdata);
            C.InputName = 'e';  
            C.OutputName = 'ufb';
            this.Cfb = C;
            this.IsStable = info.Stable;
            WC = info.wc;
            this.setTunedController;
        end
        
        % compute PID based on WC and PM
        function OK = fastdesign(this, WC, PM)
            % interactive design based on WC and PM
            OK = true;
            [Cdata, info] = tune(this.PIDTuningData,pidtuneOptions('PhaseMargin',PM,'CrossoverFrequency',WC),false);
            C = zpk.make(Cdata);
            C.InputName = 'e';  
            C.OutputName = 'ufb';
            this.Cfb = C;
            this.IsStable = info.Stable;
            this.setTunedController;
        end

        % update PID gains and loop data based on Cfb
        function setTunedController(this)
            % for idof and overloaded in 2dof
            [z p k Ts] = zpkdata(this.Cfb,'v');
            try
                [this.P this.I this.D this.N] = utPID1dof_getPIDNfromZPK(z,p,k,Ts,this.getCtrlStruct);
            catch ME %#ok<*NASGU>
                if strcmpi(this.TimeDomain,'continuous-time') && strcmpi(this.Form,'ideal')
                    this.P = eps;
                    this.I = k/this.P;
                    this.D = 0;
                    this.N = 100;
                elseif strcmpi(this.TimeDomain,'discrete-time') && strcmpi(this.Form,'ideal')
                    this.P = eps;
                    this.I = k/this.P/Ts;
                    this.D = 0;
                    this.N = 100;
                else
                    % unexpected error here but PIDN is not changed
                end
            end
            % when D is 0 for 'pdf' or 'pidf' case, make sure N is default
            if ~isempty(strfind(this.Type,'f')) && this.D==0 && isempty(this.N)
                this.N = 100;
            end
            [this.OLsys this.r2y this.r2u this.id2y this.od2y] = ...
                pidtool.utPIDgetLoopfromC(this.Cfb,this.G2);
        end
        
        % convert meta information into a structure
        function s = generateTunedStructure(this)
            s = struct( 'Type', this.Type,...
                        'Form', this.Form,...
                        'P',this.P,...
                        'I',this.I,...
                        'D',this.D,...
                        'N',this.N,...
                        'b',this.b,...
                        'c',this.c,...
                        'OLsys',this.OLsys,...
                        'r2y',this.r2y,...
                        'r2u',this.r2u,...
                        'id2y',this.id2y,...
                        'od2y',this.od2y,...
                        'Plant',this.G2,...
                        'IsStable',this.IsStable);
        end
        
        % convert meta information into a structure
        function s = generateBlockStructure(this)
            s = struct( 'Type', this.Type,...
                        'Form', this.Form,...
                        'P',this.P_Blk,...
                        'I',this.I_Blk,...
                        'D',this.D_Blk,...
                        'N',this.N_Blk,...
                        'b',this.b_Blk,...
                        'c',this.c_Blk,...
                        'OLsys',this.OLsys_Blk,...
                        'r2y',this.r2y_Blk,...
                        'r2u',this.r2u_Blk,...
                        'id2y',this.id2y_Blk,...
                        'od2y',this.od2y_Blk,...
                        'Plant',this.G2,...
                        'IsStable',this.IsStable_Blk);
        end
        
        % helper function used by plot panel
        function Data = initialParameterTableData(this) %#ok<*MANU>
            Data = cell(4,3);
            Data(:)={blanks(4)};
            Data(1,1) = {'P'};
            Data(2,1) = {'I'};
            Data(3,1) = {'D'};
            Data(4,1) = {'N'};
        end
        
        % copy tuned data to block data after applying
        function resetBlockParameters(this)
            this.P_Blk = this.P;
            this.I_Blk = this.I;
            this.D_Blk = this.D;
            this.N_Blk = this.N;
            this.b_Blk = this.b;
            this.c_Blk = this.c;
            this.setBaseline;
        end
        
        % convert control configuration into a structure 
        function ctrlstruct = getCtrlStruct(this)
            ctrlstruct = struct('Controller',this.Type,...
                                'Form',this.Form,...
                                'TimeDomain',this.TimeDomain,...
                                'IntegratorMethod',this.IntMethod,...
                                'FilterMethod',this.DerMethod);
        end
        
        % get block loop stability
        function isStable = getBlockStability(this)
            OLData = getPIDTuningData(this.G2*this.Cfb_Blk,'p',0);
            isStable = OLData.checkCL([],[],OLData.LoopSign);
        end
        
    end    
end
