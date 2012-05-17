classdef (Hidden = true) piddata < ltipack.ltidata
    % Class definition for @piddata for SISO PID data object
    % Subclasses: piddataS and piddataG
    
    %   Author(s): Rong Chen
%   Copyright 2009-2010 The MathWorks, Inc.
    %	$Revision: 1.1.8.4.2.2 $  $Date: 2010/06/24 19:43:13 $
    
    % Internal parameterization is {P I D T} in parallel form:
    %       P + I*(1/s) + D/(T+1/s)
    % Discretization means replace integrators above with their discrete
    % counterpart based on selected formula
    %       for 'ForwardEuler':     1/s --> Ts/(z-1)
    %       for 'BackwardEuler':    1/s --> Ts*z/(z-1)
    %       for 'Trapezoidal':      1/s --> Ts*(z+1)/2/(z-1)
    % I/O size is always 1x1 and delay structure is always 0    
    
    properties
        IFormula = 'F' % "F", "B" or "T"
        DFormula = 'F' % "F", "B" or "T"
    end
    
    %% Public methods
    methods
        
        function value = getType(this)
            % get PID type based on PID values
            % convert to internal parameterization
            [P I D T] = utGetPIDT(this);
            % compute type
            if P==0 && I~=0 && D==0
                value = 'I';
            else
                value = 'P';
                if I~=0
                    value = [value 'I'];
                end
                if D~=0
                    value = [value 'D'];
                    if T~=0
                        value = [value 'F'];
                    end
                end
            end
        end
        
        function [ny,nu] = iosize(~)
            % i/o size is fixed as 1x1
            ny = 1; nu = 1;
            if nargout<2
                ny = [ny nu];
            end
        end
        
        function [z,p,k] = iodynamics(PID)
            % Compute zeros, poles and gain.
            [Num, Poles] = getTF(PID);
            Zeros = roots(Num);
            z = {Zeros};
            p = {Poles};
            k = Num(end-length(Zeros));
        end

        function boo = isfinite(~)
            % Returns TRUE since PID is always finite.
            % when using PID wrapper object, PID parameters are restricted
            % to always represent a finite PID.  When using PID data object
            % internally, although we don't provide such checking mechanism
            % in the property set method, we expect valid values for these
            % properties as well.   
            boo = true;        
        end

        function [boo,PID] = isproper(PID,varargin)
            % Returns TRUE if PID is proper.
            % Convert to internal parameterization
            [~, ~, D, T] = utGetPIDT(PID);
            % PID is proper except when one of the two conditions is present
            % (1) it is a PD or PID in continuous time
            % (2) it is a PD or PID in discrete time and DFormula is Forward Euler
            boo = D==0 || T~=0 || ~(PID.Ts==0 || PID.DFormula=='F');
        end
        
        function boo = isreal(~)
            % Returns TRUE since PID parameters are always real.
            % when using PID wrapper object, PID parameters are restricted
            % to always represent a real PID.  When using PID data object
            % internally, although we don't provide such checking mechanism
            % in the property set method, we expect valid values for these
            % properties as well.   
            boo = true;
        end

        function boo = isstatic(PID)
            % True for static gains (when PID type is P).
            % Convert to internal parameterization
            [~, I, D] = utGetPIDT(PID);
            % true if it is a P-only controller
            boo = (I==0)&&(D==0);
        end
        
        function n = order(PID)
            % Computes order of PID
            % Convert to internal parameterization
            [~, I, D, T] = utGetPIDT(PID);
            if PID.Ts==0
                n = (I~=0)+(D~=0)*(1+(T==0));
            else
                n = (I~=0)+(D~=0)*(1+(T==0)*(PID.DFormula=='F'));
            end
        end
        
        function PID = pade(PID,~,~,~)
        end
        
        function p = pole(PID,varargin)
            % Compute poles based on Ts and discretization methods
            [~, p] = getTF(PID);
        end
        
        function [Dsim,dt,tf,SimInfo] = trespSetUp(PID,RespType,dt,tf,varargin)
            % Build discrete models for independent simulation of each input channel.
            [Dsim,dt,tf,SimInfo] = trespSetUp(ss(PID),RespType,dt,tf,[]);
        end

        function boo = utIsIOScaling(PID)
            % Return true if PID is a pure gain.
            boo = isstatic(PID);
        end
        
        function D = upsample(varargin) %#ok<STOUT>
            % Not supported for PID models.
            ctrlMsgUtils.error('Control:general:NotSupportedModelsofClass','upsample','pid')
        end

        function [z,k] = zero(PID)
            % Computes transmission zeros.
            [z,~,k] = iodynamics(PID);
            z = z{1};
        end

        function D = getsubsys(D,rowIndex,colIndex)
           % Subsystem extraction: error or no-op
           if ~((ischar(rowIndex) || numel(rowIndex)==1) && ...
                 (ischar(colIndex) || numel(colIndex)==1))
              ctrlMsgUtils.error('Control:ltiobject:subsref9')
           end
        end
        
        function D = utGrowIO(~,varargin) %#ok<STOUT>
           % Grows I/O size: Not allowed for PIDs
           ctrlMsgUtils.error('Control:ltiobject:subsasgn10')
        end
        
        function D = setsubsys(D,rowIndex,colIndex,rhs)
           % Modifies subsystem via SYS(I,J) = RHS.
           if isempty(rhs)
              % SYS(i,:) = [] or SYS(:,j) = []: error unless no-op
              if ~((ischar(rowIndex) || isempty(rowIndex)) && ...
                    (ischar(colIndex) || isempty(colIndex)))
                 ctrlMsgUtils.error('Control:ltiobject:subsasgn8')
              end
           elseif (ischar(rowIndex) || numel(rowIndex)==1) && ...
                 (ischar(colIndex) || numel(colIndex)==1)
              % Overwrite whole PID
              D = rhs;
           else
              % Note: Cannot support sys(:,[1 1]) = [1 2] because pid([1 2]) is a 
              % 1x2 array, and cannot support sys([],[]) = tf because can't convert
              % 0x0 tf to PID
              ctrlMsgUtils.error('Control:ltiobject:subsasgn9')
           end
        end
        
    end
    
    %% Protected methods (utilities)
    methods(Access=protected)
        
        % compute frequency responses of an integrator
        function [valI valD] = utGetIntFreqResp(this, s)
            % s is a vector of complex frequencies
            Ts = abs(this.Ts);
            if Ts==0
                valI = 1./s;
                valD = valI;
            else
                switch this.IFormula
                    case 'F'
                        valI = Ts./(s-1);
                    case 'B'
                        valI = Ts*s./(s-1);
                    case 'T'
                        valI = (Ts/2)*(s+1)./(s-1);
                end
                switch this.DFormula
                    case 'F'
                        valD = Ts./(s-1);
                    case 'B'
                        valD = Ts*s./(s-1);
                    case 'T'
                        valD = (Ts/2)*(s+1)./(s-1);
                end
            end
        end
        
        % Compute num and poles from this PID
        function [Num Pole] = getTF(this)
            % convert to internal parameterization
            [P I D T] = utGetPIDT(this);
            % get Ts
            Ts = abs(this.Ts);
            % start computation
            if I==0
                % p
                Pole = zeros(0,1);
                Num = P; Den = 1;
            else
                % i and pi
                if Ts==0
                    Pole = 0;
                    Num = [P I]; Den = [1 0]; 
                else
                    Pole = 1;
                    Den = [1 -1];
                    switch this.IFormula
                        case 'F'
                            Num = [P I*Ts-P];
                        case 'B'
                            Num = [P+I*Ts -P];
                        case 'T'
                            Num = [P+I*Ts/2 I*Ts/2-P];
                    end
                end
            end
            % pd, pdf, pid and pidf 
            if D~=0
                if Ts==0
                    Pole = [Pole;-1/T];
                    NumDF = [1 0]*D; DenDF = [T 1];
                else
                    switch this.DFormula
                        case 'F'
                            Pole = [Pole;1-Ts/T];
                            DenDF = [T Ts-T];
                        case 'B'
                            Pole = [Pole;T/(T+Ts)];
                            DenDF = [T+Ts -T];
                        case 'T'
                            Pole = [Pole;(2*T-Ts)/(2*T+Ts)];
                            DenDF = [T+Ts/2 Ts/2-T];
                    end
                    NumDF = [1 -1]*D; 
                end
                Pole = Pole(~isinf(Pole));
                Num = conv(Num,DenDF) + conv(Den,NumDF);
                Den = conv(Den,DenDF);
                Num = Num/Den(find(Den~=0,1,'first'));
            end
        end  
        
    end

    %% Abstract methods
    methods(Abstract)
        utGetPIDT(this)
    end
    
    %% Static methods
    methods(Static)    
                
       function [Kp,Ki,Kd,Tf] = convert(Num,Poles,Ts,IFormula,DFormula,STDFlag)
          % Computes coefficients Kp,Ki,Kd,Tf of the Parallel Form given the
          % numerator NUM and the poles of the controller transfer function.
          % An error is thrown if the transfer function does not represent a
          % PID controller. When converting to the Standard Form, set
          % STDFLAG=true to return Kp,Ki,Kd with the same sign when possible.
          tol = 1e3*eps;
          if any(isnan(Num))
             ctrlMsgUtils.error('Control:ltiobject:pidOperations2')
          end
          if Ts==0
             pI = Poles(find(Poles==0,1));
             pD = Poles(find(Poles~=0,1));
          else
             if abs(prod(1-Poles))<tol*prod(1+abs(Poles))
                % z=1 is a root of poly(Poles) within the tolerance TOL
                pI = 1;  
             else
                pI = [];
             end
             if numel(Poles)==1+numel(pI)
                % Note: This approach has superior accuracy when there are
                % two poles close to z=1 because it corrects the error
                % introduced when replacing the pole closest to z=1 by z=1.
                pD = prod(Poles);
             else
                pD = [];
             end
          end
          % validate num and poles in general case
          improperPID = (Ts==0 || DFormula(1)=='F');  % true if PD/PID can be improper
          nzMax = numel(pI) + max(numel(pD),double(improperPID));
          if ~(numel(pI)+numel(pD)==numel(Poles) && numel(Num)<=nzMax+1)
             ctrlMsgUtils.error('Control:ltiobject:pidOperations2')
          end
          % compute Tf and coefficients for I term and D term
          [NumI DenI] = getNumDenITerm(Ts,IFormula);
          [NumD DenD Tf] = getNumDenDTerm(Ts,DFormula,pD);
          if Tf<0 || isinf(Tf)
             % Tf must be positive and finite
             ctrlMsgUtils.error('Control:ltiobject:pidOperations2')
          end
          % patch Num at the end for P, PD, PDF
          if isempty(pI)
             Num = conv(Num,[1 -double(Ts~=0)]);
          end
          % compute gains
          h = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>
          A = [conv(DenI,DenD);conv(NumI,DenD);conv(NumD,DenI)];  % 3x3
          y = [zeros(1,3-length(Num)),Num];
          Gains = y/A;
          Gains([false isempty(pI) (isempty(pD) && length(Num)<3)]) = 0;
          if any(isinf(Gains))
             ctrlMsgUtils.error('Control:ltiobject:pidOperations2')
          end
          Kp = Gains(1);
          Ki = Gains(2);
          Kd = Gains(3);
          if STDFlag && any(Kp*Gains<0)
             % Trying enforcing consistent signs for Standard Form
             Gains(Kp*Gains<0) = 0;
             if all(abs(Gains*A-y) <= 10*tol*(abs(Gains)*abs(A)+abs(y)))
                Ki = Gains(2);  Kd = Gains(3);
             end
          end
       end
        
        function [P I D T] = convertPIDF(From,To,P,I,D,T)
           if strcmpi(From,'Parallel') && strcmpi(To,'Standard')
              if P==0
                 if I==0 && D==0
                    I = inf;
                    D = 0;
                    T = inf;
                 else
                    % cannot convert I or D only control to pidstd
                    ctrlMsgUtils.error('Control:ltiobject:pidOperations3')
                 end
              else
                 if I==0
                    I = inf;
                 else
                    I = P/I;
                 end
                 D = D/P;
                 if D==0
                    T = inf;
                 else
                    T = D/T;
                 end
                 if I<0 || D<0
                    ctrlMsgUtils.error('Control:ltiobject:pidOperations7')
                 end
              end
           elseif strcmpi(From,'Standard') && strcmpi(To,'Parallel')
              I = P/I;
              T = D/T;
              D = P*D;
           end
        end
        
        function StrI = utGetStrI(Ts,Formula)
            % display string for 1/s
            if Ts==0
                StrI = [' 1 ';...
                        '---';...
                        ' s '];
            else
                switch Formula(1)
                    case 'F'
                        StrI = ['  Ts  ';...
                                '------';...
                                '  z-1 '];
                    case 'B'
                        StrI = [' Ts*z ';...
                                '------';...
                                '  z-1 '];
                    case 'T'
                        StrI = ['Ts*(z+1)';...
                                '--------';...
                                '2*(z-1) '];
                end
            end
        end
        
        function StrI = utGetStrForS(Ts,Formula)
            % display string for s
            if Ts==0
                StrI = [' ';...
                        's';...
                        ' '];
            else
                switch Formula(1)
                    case 'F'
                        StrI = ['  z-1 ';...
                                '------';...
                                '  Ts  '];
                    case 'B'
                        StrI = ['  z-1 ';...
                                '------';...
                                ' Ts*z '];
                    case 'T'
                        StrI = ['2*(z-1) ';...
                                '--------';...
                                'Ts*(z+1)'];
                end
            end
        end
        
        function StrD = utGetStrD_Parallel(Ts,Formula)
            % display string for s/(Tf*s+1)
            if Ts==0
                StrD = ['   s    ';...
                        '--------';...
                        ' Tf*s+1 '];
            else
                switch Formula(1)
                    case 'F'
                        StrD = ['     1     ';...
                                '-----------';...
                                'Tf+Ts/(z-1)'];
                    case 'B'
                        StrD = ['      1      ';...
                                '-------------';...
                                'Tf+Ts*z/(z-1)'];
                    case 'T'
                        StrD = ['         1         ';...
                                '-------------------';...
                                'Tf+Ts/2*(z+1)/(z-1)'];
                end
            end
        end
        
        function StrD = utGetStrD_Standard(Ts,Formula)
            % display string for s/(Td/N*s+1)
            if Ts==0
                StrD = ['     s      ';...
                        '------------';...
                        ' (Td/N)*s+1 '];
            else
                switch Formula(1)
                    case 'F'
                        StrD = ['       1       ';...
                                '---------------';...
                                '(Td/N)+Ts/(z-1)'];
                    case 'B'
                        StrD = ['        1        ';...
                                '-----------------';...
                                '(Td/N)+Ts*z/(z-1)'];
                    case 'T'
                        StrD = ['           1           ';...
                                '-----------------------';...
                                '(Td/N)+Ts/2*(z+1)/(z-1)'];
                end
            end
        end
        
        function [IF,DF,newForm] = getTargetFormulas(IF,DF,Options)
           % Resolves target IFormula and DFormula in conversions to PID/PIDSTD.
           % The inputs IF and DF provide default values when IFormula/DFormula
           % are unspecified in OPTIONS. NEWFORM is true if there is a change of 
           % formula.
           newForm = false;
           IFOpt = Options.IFormula;
           if ~isempty(IFOpt)
              newForm = newForm || ~strcmp(IF,IFOpt);
              IF = IFOpt;
           end
           DFOpt = Options.DFormula;
           if ~isempty(DFOpt)
              newForm = newForm || ~strcmp(DF,DFOpt);
              DF = DFOpt;
           end
        end
        
    end
    
end

%% local function --------------------------------------
function [Num,Den] = getNumDenITerm(Ts,Formula)
% Returns transfer function of integrator 1/s or its discrete-time equivalent.
if Ts==0
   Num = [0 1];
   Den = [1 0];
else
   switch Formula(1)
      case 'F'
         Num = [0 Ts];
      case 'B'
         Num = [Ts 0];
      case 'T'
         Num = [Ts/2 Ts/2];
   end
   Den = [1 -1];
end
end

function [Num Den Tf] = getNumDenDTerm(Ts,Formula,pD)
% Returns transfer function of derivative term s/(tau*s+1) or its discrete-time 
% equivalent. PD specifies the root of tau*s+1.
if isempty(pD)
   if Ts==0
      Tf = 0;
      Num = [1 0];
      Den = [0 1];
   else
      Tf = 0;
      Num = [1 -1]/Ts;
      Den = [0 1];
   end
else
   if Ts==0
      Tf = -1/pD;
      Num = [-pD 0];
      Den = [1 -pD];
   else
      alpha = (1-pD)/Ts;
      switch Formula(1)
         case 'F'
            Tf = 1/alpha;
         case 'B'
            Tf = pD/alpha;
         case 'T'
            Tf = (1+pD)/2/alpha;
      end
      Num = [1 -1]*alpha;
      Den = [1 -pD];
   end
end
end
