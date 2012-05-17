classdef (Hidden = true) piddataP < ltipack.piddata
    % Class definition for @piddataP (pidp object data)
    
    %   Author(s): Rong Chen
    %   Copyright 2009-2010 The MathWorks, Inc.
    %	 $Revision: 1.1.8.2.2.2 $  $Date: 2010/06/24 19:43:16 $
    
    % Formula: Kp + Ki*(1/s) + Kd*s/(Tf*s+1)) or Kp + Ki*(1/s) + Kd/(Tf+1/s))
    % Discretization means replace integrators above with discretizers
    %   for 'ForwardEuler':     1/s --> Ts/(z-1)
    %   for 'BackwardEuler':    1/s --> Ts*z/(z-1)
    %   for 'Trapezoidal':      1/s --> Ts*(z+1)/2/(z-1)
    % Delay structure is initialized as 0 and remains 0    
    
    properties
        % 1DOF PID in Parallel form
        Kp      % proportional gain (real, finite, scalar)
        Ki      % integral gain (real, finite, scalar)
        Kd      % derivative gain (real, finite, scalar)
        Tf      % derivative filter time constant (real, finite, scalar)
    end
    
    %% Public methods
    methods
        
        % constructor
        function this = piddataP(Kp,Ki,Kd,Tf,Ts)
            if nargin == 5
                % parameters
                this.Kp = Kp;
                this.Ki = Ki;
                this.Kd = Kd;
                this.Tf = Tf;
                this.Ts = Ts;
                this.Delay = ltipack.utDelayStruct(1,1,false);
            end
        end
        
        function [P I D T] = utGetPIDT(this)
            % abstract method cconverting PID to internal parameterization
            P = this.Kp;
            I = this.Ki;
            D = this.Kd;
            T = this.Tf;
        end
        
        function PIDS = pidstd(PID,Options)
           % Parallel to standard conversion
           % When specified, OPTIONS is a struct/object containing the fields 
           % IFormula and DFormula.
           Ts = PID.Ts;
           if nargin>1 && Ts~=0
              [IF,DF,newForm] = ltipack.piddata.getTargetFormulas(PID.IFormula,PID.DFormula,Options);
           else              
              IF = PID.IFormula;  DF = PID.DFormula;  newForm = false;  
           end
           if newForm
              % Convert to parallel form with new formulas 
              [Num Poles] = getTF(PID);
              [Kp,Ki,Kd,Tf] = ltipack.piddata.convert(Num,Poles,Ts,IF,DF,true); %#ok<*PROP>
           else
              Kp = PID.Kp;  Ki = PID.Ki;  Kd = PID.Kd;  Tf = PID.Tf;
           end
           % Parallel to standard conversion with matching formulas
           [Kp,Ti,Td,N] = ltipack.piddata.convertPIDF('Parallel','Standard',Kp,Ki,Kd,Tf);
           PIDS = ltipack.piddataS(Kp,Ti,Td,N,Ts);
           if Ts~=0
              PIDS.IFormula = IF;
              PIDS.DFormula = DF;
           end
        end
        
        function PID = pid(PID,Options)
           % Parallel to parallel conversion
           % When specified, OPTIONS is a struct/object containing the fields 
           % IFormula and DFormula.
           Ts = PID.Ts;
           if nargin>1 && Ts~=0
              [IF,DF,newForm] = ltipack.piddata.getTargetFormulas(PID.IFormula,PID.DFormula,Options);
              if newForm
                 [Num Poles] = getTF(PID);
                 [PID.Kp,PID.Ki,PID.Kd,PID.Tf] = ltipack.piddata.convert(Num,Poles,Ts,IF,DF,false);
                 PID.IFormula = IF;
                 PID.DFormula = DF;
              end
           end
        end
    
        function PID = uminus(PID)
            % Computes -PID.
            PID.Kp = -PID.Kp;
            PID.Ki = -PID.Ki;
            PID.Kd = -PID.Kd;
        end
        
    end

    methods(Static)
        
        function D = array(size)
            % Create a pid array of a given size
            D = ltipack.piddataP.newarray(size);
        end
        
    end
    
end