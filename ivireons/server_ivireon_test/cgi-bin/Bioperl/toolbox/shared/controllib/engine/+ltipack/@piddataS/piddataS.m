classdef (Hidden = true) piddataS < ltipack.piddata
    % Class definition for @piddataS (pid object data)
    
    %   Author(s): Rong Chen
    %   Copyright 2009-2010 The MathWorks, Inc.
    %	 $Revision: 1.1.8.2.2.2 $  $Date: 2010/06/24 19:43:18 $
    
    % Formula: Kp*(1 + 1/Ti*(1/s) + Td*s/(Td/N*s+1)) or Kp*(1 + 1/Ti*(1/s) + Td/(Td/N+1/s))
    % Discretization means replace integrators above with discretizers
    %   for 'ForwardEuler':     1/s --> Ts/(z-1)
    %   for 'BackwardEuler':    1/s --> Ts*z/(z-1)
    %   for 'Trapezoidal':      1/s --> Ts*(z+1)/2/(z-1)
    % Delay structure is initialized as 0 and remains 0    
    
    properties
        % 1DOF PID in Standard form
        Kp      % proportional gain (real, finite, scalar)
        Ti      % integral time (real, non-zero, scalar)
        Td      % derivative time (real, finite, scalar)
        N       % filter divisor (real, non-zero, scalar)
    end
    
    %% Public methods
    methods
        
        % constructor
        function this = piddataS(Kp,Ti,Td,N,Ts)
            if nargin == 5
                % parameters
                this.Kp = Kp;
                this.Ti = Ti;
                this.Td = Td;
                this.N = N;
                this.Ts = Ts;
                this.Delay = ltipack.utDelayStruct(1,1,false);
            end
        end
        
        function [P I D T] = utGetPIDT(this)
            % abstract method cconverting PID to internal parameterization
            P = this.Kp;
            I = this.Kp/this.Ti;
            D = this.Kp*this.Td;
            T = this.Td/this.N;
        end
        
        function PID = pid(PIDS,Options)
           % Standard to parallel conversion
           % When specified, OPTIONS is a struct/object containing the fields 
           % IFormula and DFormula.
           Ts = PIDS.Ts;
           if nargin>1 && Ts~=0
              [IF,DF,newForm] = ltipack.piddata.getTargetFormulas(PIDS.IFormula,PIDS.DFormula,Options);
           else
              IF = PIDS.IFormula;  DF = PIDS.DFormula;  newForm = false;
           end
           if newForm
              % Convert to parallel form with new formulas
              [Num Poles] = getTF(PIDS);
              [Kp,Ki,Kd,Tf] = ltipack.piddata.convert(Num,Poles,Ts,IF,DF,false); %#ok<*PROP>
           else
              % Transform coefficients
              [Kp,Ki,Kd,Tf] = ltipack.piddata.convertPIDF('Standard','Parallel',PIDS.Kp,PIDS.Ti,PIDS.Td,PIDS.N);
           end
           PID = ltipack.piddataP(Kp,Ki,Kd,Tf,Ts);    
           if Ts~=0
              PID.IFormula = IF;
              PID.DFormula = DF;
           end
        end
        
        function PIDS = pidstd(PIDS,Options)
           % Standard to standard conversion
           % When specified, OPTIONS is a struct/object containing the fields 
           % IFormula and DFormula.
           Ts = PIDS.Ts;
           if nargin>1 && Ts~=0
              [IF,DF,newForm] = ltipack.piddata.getTargetFormulas(PIDS.IFormula,PIDS.DFormula,Options);
              if newForm
                 [Num Poles] = getTF(PIDS);
                 [Kp,Ki,Kd,Tf] = ltipack.piddata.convert(Num,Poles,Ts,IF,DF,true);
                 [PIDS.Kp,PIDS.Ti,PIDS.Td,PIDS.N] = ltipack.piddata.convertPIDF('Parallel','Standard',Kp,Ki,Kd,Tf);
                 PIDS.IFormula = IF;
                 PIDS.DFormula = DF;
              end
           end
        end
        
        function PID = uminus(PID)
            % Computes -PID.
            PID.Kp = -PID.Kp;
        end
        
        
    end

    methods(Static)
        
        function D = array(size)
            % Create a pid array of a given size
            D = ltipack.piddataS.newarray(size);
        end
        
    end
    
end
