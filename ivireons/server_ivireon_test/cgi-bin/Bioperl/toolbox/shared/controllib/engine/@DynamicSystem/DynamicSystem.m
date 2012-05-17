classdef (SupportClassFunctions=true) DynamicSystem < InputOutputModel
   % Dynamic System objects.
   %
   %   Dynamic systems are input/output models with internal dynamics or
   %   memory. Integrators, delays, transfer functions, and state-space
   %   models are some examples of dynamic systems.
   %
   %   All dynamic system objects in Control System Toolbox derive from the 
   %   @DynamicSystem superclass. This class is not user-facing and cannot 
   %   be instantiated. User-facing subclasses of @DynamicSystem include:
   %     * LTI models (@tf, @ss, @pid, @frd, ...)
   %     * Dynamic Control Design blocks (ltiblock.ss, ltiblock.pid,...).
   %
   %   See also LTI, CONTROLDESIGNBLOCK.
   
   %   Author(s): P. Gahinet
   %   Copyright 1986-2010 The MathWorks, Inc.
   %	 $Revision: 1.1.8.6 $  $Date: 2010/05/10 17:36:48 $
   
   % Note: Use (CaseInsensitiveProperties = true, TruncatedProperties = true)
   % when . overload is no longer necessary.
   
   % Public properties with restricted value (dependent to avoid issues
   % with data validation at load time)
   properties (Access = public, Dependent)
      % Time unit (string, default = '').
      %
      % This property specifies the unit for the time variable, sampling time 
      % Ts, and time delays. It can be set to any of the following strings: 
      % 'nanoseconds', 'microseconds', 'milliseconds', 'seconds', 'minutes', 'hours', 
      % 'days', 'weeks', 'months', or 'years'. The default value is '' to mean 
      % "unspecified".
      TimeUnit
      % Input channel names (string vector, default = empty string for all 
      % channels).
      %
      % This property can be set to:
      %  * A string for single-input models, for example, 'torque' 
      %  * A string vector for multi-input models, for example, 
      %    {'thrust' ; 'aileron deflection'}
      % Use the empty string '' for unnamed input channels.
      InputName
      % Input channel units (string vector, default = empty string for all 
      % channels).
      %
      % Use this property to keep track of input signal units. You can set 
      % "InputUnit" to:
      %  * A string for single-input models, for example, 'kg' 
      %  * A string vector for multi-input models, for example, {'m/s';'Nm'}
      InputUnit
      % Input channel groups (structure, default = struct with no field).
      %
      % The "InputGroup" property partitions the input channels of MIMO 
      % systems into groups and lets you refer to each group by name. Input
      % groups are specified as a structure whose field names are the group 
      % names and whose field values are the input channels belonging to 
      % each group. For example,
      %    sys.InputGroup.controls = [1 2]
      %    sys.InputGroup.noise = [3 5]
      % creates two input groups labeled "controls" and "noise" that include
      % input channels 1,2 and 3,5, respectively. You can then extract the 
      % transfer function from the "controls" inputs to all outputs using 
      %    sys(:,'controls')
      InputGroup
      % Output channel names (string vector, default = empty string for all
      % channels).
      %
      % This property can be set to:
      %  * A string for single-output models, for example, 'power' 
      %  * A string vector for multi-output models, for example, 
      %    {'altitude' ; 'pitch angle'}
      % Use the empty string '' for unnamed output channels.
      OutputName
      % Output channel units (string vector, default = empty string for all 
      % channels).
      %
      % Counterpart of "InputUnit" for output channels. Type
      % "help DynamicSystem.InputUnit" for details.
      OutputUnit
      % Output channel groups (structure, default = struct with no field).
      %
      % Counterpart of "InputGroup" for output channels. Type
      % "help DynamicSystem.InputGroup" for details.
      OutputGroup
      % System name (string, default = '').
      %
      % Example: sys.Name = 'pitch axis' labels SYS as a pitch axis model.
      Name
      % User notes (default: {}).
      %
      % This property can store any text (string or cell array of strings).
      % For example, sys.Notes = 'This model was created on Jan. 1st, 2000'.       
      Notes
   end
   
   % Public properties with arbitrary value
   properties (Access = public)
      % Additional information or data about the system (default = []). 
      % 
      % This property can store any MATLAB data type.
      UserData;
   end
   
   % Private properties (raw data, not get/set methods). Methods should
   % interact with these properties rather than their public counterparts
   properties (Access = protected)
      % String or [] for default value 's'
      TimeUnit_
      % Nu-by-1 string vector or [] for default value {'';...;''}
      InputName_
      % Nu-by-1 string vector or [] for default value {'';...;''}
      InputUnit_
      % Structure
      InputGroup_ = struct;
      % Ny-by-1 string vector or [] for default value {'';...;''}
      OutputName_
      % Ny-by-1 string vector or [] for default value {'';...;''}
      OutputUnit_
      % Structure
      OutputGroup_ = struct;
      % String or [] for default value ''
      Name_;
      % String or [] for default value {}
      Notes_;
   end
   
   properties (Access = protected, Transient)
      % Setting CrossValidation=false defers all consistency checks in
      % the SET methods for public properties. Other types of data validation
      % (e.g., enforcing the correct datatype) are not affected. This flag
      % is needed to support multi-property SET operations.
      CrossValidation_ = true;
   end
   
   methods (Abstract, Access = protected)
      % TO BE IMPLEMENTED BY ALL SUBCLASSES
      Ts = getTs_(sys)       % get sampling time(s)
      sys = setTs_(sys,Ts)   % set sampling time(s)
   end
      
   %% DATA ABSTRACTION INTERFACE (DYNAMICSYSTEM EXTENSION)
   methods (Access = protected)
      
      %% MODEL CHARACTERISTICS
      boo = isstable_(sys)
      ns = order_(sys)
      function [boo,blk] = isproper_(blk,varargin)
         % Default implementation
         boo = true;
      end
      function boo = isct_(sys)
         % True for single-rate continuous-time dynamic systems.
         Ts = getTs_(sys);
         boo = (isscalar(Ts) && Ts==0);
      end
      function boo = isdt_(sys)
         % True for single-rate discrete-time dynamic systems.
         Ts = getTs_(sys);
         boo = (isscalar(Ts) && (Ts~=0 || isstatic_(sys)));
      end
      [a,b,c,d,Ts] = ssdata_(sys,varargin)
      [a,b,c,d,e,Ts] = dssdata_(sys,varargin)
      [num,den,Ts] = tfdata_(sys,varargin)
      [z,p,k,Ts] = zpkdata_(sys,varargin)
      [resp,freq,Ts] = frdata_(sys,varargin)
      [Kp,Ki,Kd,Tf,Ts] = piddata_(sys,varargin)
      [Kp,Ti,Td,N,Ts] = pidstddata_(sys,varargin)
      sys = checkComputability(sys,ResponseType,varargin) % REVISIT: evolve
      function sys = checkDataConsistency(sys)
         % Default = no-op
      end
      
      %% BINARY OPERATIONS
      % Note: op_ is never called for class X if X.isCombinable(op) is false
      [sys,SingularFlag] = connect_(sys,k,feedin,feedout,iu,iy)
   
      %% ANALYSIS
      [g,dceq] = dcgain_(sys)
      fresp = evalfr_(sys,s)
      [h,SingularWarn] = freqresp_(sys,w)
      s = allmargin_(sys)
      fb = bandwidth_(sys,drop)
      n = normh2_(sys)
      [n,fpeak] = norminf_(sys,tol)
      p = pole_(sys,varargin)
      [z,g] = zero_(sys,varargin)

      %% TRANSFORMATIONS
      sys = repsys_(sys,s)
      [sys,gic] = c2d_(sys,Ts,options)
      sys = d2c_(sys,options)
      sys = d2d_(sys,Ts,options)
      sys = upsample_(sys,L)
      [sys,icmap] = delay2z_(sys)
      sys = pade_(sys,Ni,No,Nf)
      [G1,G2,varargout] = stabsep_(G,Options)
      [H,H0,varargout] = modsep_(G,N,varargin)
      [sys,u] = minreal_(sys,tol,varargin)
      [g,varargout] = hsvd_(sys,options)
      [sysb,g,varargout] = balreal_(sys,options)
      rsys = balred_(sys,orders,BalData,Options)
      sys = interp_(sys,w)  % FRD interpolation
      
      %% DESIGN
      [C Info Merit] = pidtune_(G,C,Options)
      
      %% STATE-SPACE MODELS
      [sys,xkeep] = sminreal_(sys)
      sys = augstate_(sys)
      sys = ss2ss_(sys,T,l,u,p)
      sys = xperm_(sys,perm)
      W = gram_(sys,type)
      [sys,varargout] = canon_(sys,Type,condt)
      [p,q] = covar_(sys,w,rw)
      sys = modred_(sys,method,elim)
   end
   %%%%%%%%%%%%%%%%% END DATA ABSTRACTION INTERFACE %%%%%%%%%%%%%%%%%%%%%%
      
   
   % PUBLIC METHODS
   methods
      
      function [boo,sys] = isproper(sys,varargin)
         %ISPROPER  True for proper dynamic systems.
         %
         %   ISPROPER(SYS) returns TRUE if the dynamic system SYS is proper
         %   (relative degree<=0, causal), and FALSE otherwise. If SYS is an 
         %   array of models, ISPROPER(SYS) is true if all models are proper.
         %
         %   If SYS is a proper state-space model with a singular E matrix,
         %   [ISP,SYSR] = ISPROPER(SYS) also returns an equivalent model SYSR
         %   with fewer states and a nonsingular E matrix.
         %
         %   See also POLE, ZERO, DYNAMICSYSTEM.
         try
            [boo,sys] = isproper_(sys,varargin{:});
         catch ME
            throw(ME)
         end
      end
      
      function boo = isct(sys)
         %ISCT  True for continuous-time dynamic systems.
         %
         %   ISCT(SYS) returns true if the dynamic system SYS is continuous
         %   (zero sampling time) and false otherwise.
         %
         %   See also ISDT, ISSTATIC, DYNAMICSYSTEM.
         boo = isct_(sys);
      end
      
      function boo = isdt(sys)
         %ISDT  True for discrete-time dynamic systems.
         %
         %   ISDT(SYS) returns true if the dynamic system SYS is discrete
         %   and false otherwise. ISDT always returns true for empty systems 
         %   or static gains.
         %
         %   See also ISCT, ISSTATIC, DYNAMICSYSTEM.
         boo = isdt_(sys);
      end
      
      function boo = isstable(sys)
         %ISSTABLE  Tests stability of dynamic system.
         %
         %   ISSTABLE(SYS) returns TRUE if the dynamic system SYS has stable
         %   dynamics, and FALSE otherwise.  For arrays of dynamic systems, 
         %   ISSTABLE returns a logical array where the k-th entry indicates 
         %   the stability of the k-th model.
         %
         %   ISSTABLE is only supported for analytical models with a finite 
         %   number of poles.
         %
         %   See also POLE, DYNAMICSYSTEM.
         boo = isstable_(sys);
      end
      
      function ns = order(sys)
         %ORDER  Dynamic system order.
         %
         %   NS = ORDER(SYS) returns the system order NS.  For state-space
         %   models, NS is the number of states.  For transfer functions
         %   and zero-pole-gain models, NS is the generic number of states
         %   needed to build an equivalent state-space model.  For proper,
         %   SISO models, the order coincides with the number of poles.
         %
         %   For system arrays SYS, NS is an array of the same size listing 
         %   the orders of each system in SYS.
         %
         %   See also POLE, BALRED, DYNAMICSYSTEM.
         if isa(sys,'FRDModel')
            ctrlMsgUtils.error('Control:general:NotSupportedModelsofClass','order',class(sys))
         else
            try
               ns = order_(sys);
            catch E
               ltipack.throw(E,'command','order',class(sys))
            end
         end
      end
      
      function boo = isStateSpace(sys)
         %ISSTATESPACE  True for state-space models.
         %
         %   ISSTATESPACE(SYS) returns TRUE if SYS is a state-space
         %   representation of a dynamical system, and FALSE otherwise.
         %
         %   See also ISSISO, ISPROPER, DYNAMICSYSTEM.
         boo = isa(sys,'StateSpaceModel');
      end

      function [g,varargout] = dcgain(sys)
         %DCGAIN  DC gain of dynamic systems.
         %
         %   K = DCGAIN(SYS) computes the steady-state (D.C. or low frequency) gain
         %   of the dynamic system SYS.
         %
         %   If SYS is an array of dynamic systems with dimensions [NY NU S1 ... Sp],
         %   DCGAIN returns an array K with the same dimensions such that
         %      K(:,:,j1,...,jp) = DCGAIN(SYS(:,:,j1,...,jp)) .
         %
         %   See also DYNAMICSYSTEM/NORM, DYNAMICSYSTEM/EVALFR, FREQRESP, DYNAMICSYSTEM.
         try
            [g,varargout{1:nargout-1}] = dcgain_(sys);
         catch ME
            ltipack.throw(ME,'command','dcgain',class(sys))
         end
      end
      
      function v = eig(sys)
         %EIG  Computes the poles of a linear system.
         %
         %   P = EIG(SYS) returns the poles of SYS (P is a column vector).
         %
         %   For state-space models, the poles are the eigenvalues of the A
         %   matrix or the generalized eigenvalues of the (A,E) pair in the
         %   descriptor case.
         %
         %   See also POLE, DAMP, ESORT, DSORT, ZERO, PZMAP.
         v = pole(sys);
      end
      
      function varargout = tzero(sys)
         %TZERO  Transmission zeros of linear systems.
         %
         %   Z = TZERO(SYS) returns the transmission zeros of the dynamic
         %   system SYS.
         %
         %   [Z,GAIN] = TZERO(SYS) also returns the transfer function
         %   gain if the system is SISO.
         %
         %   Z = TZERO(A,B,C,D) works directly on the state space matrices
         %   and returns the transmission zeros of the state-space system:
         %           .
         %           x = Ax + Bu     or   x[n+1] = Ax[n] + Bu[n]
         %           y = Cx + Du           y[n]  = Cx[n] + Du[n]
         %
         %   See also ZERO, PZMAP, POLE, LTI, DYNAMICSYSTEM.
         try
            [varargout{1:nargout}] = zero(sys);
         catch ME
            ltipack.throw(ME,'command','tzero',class(sys))
         end
      end
      
      function fresp = evalfr(sys,s)
         %EVALFR  Evaluates frequency response at a single frequency.
         %
         %   FRESP = EVALFR(SYS,X) evaluates the transfer function of the
         %   continuous- or discrete-time linear model SYS at the complex
         %   number S=X or Z=X.
         %
         %   EVALFR is a simplified version of FREQRESP meant for quick
         %   evaluation of the response at a single point. Use FREQRESP
         %   to compute the frequency response over a grid of frequencies.
         %
         %   See also FREQRESP, BODE, SIGMA, DYNAMICSYSTEM.
         error(nargchk(2,2,nargin,'struct'))
         if length(s)~=1,
            ctrlMsgUtils.error('Control:analysis:evalfr1');
         end
         try
            fresp = evalfr_(sys,s);
         catch E
            ltipack.throw(E,'command','evalfr',class(sys))
         end
      end
      
      function h = freqresp(sys,w)
         %FREQRESP  Frequency response of dynamic systems.
         %
         %   H = FREQRESP(SYS,W) computes the frequency response H of the
         %   dynamic system SYS at the frequencies specified by the vector W.
         %   These frequencies should be real and in radians/second.
         %
         %   If SYS has NY outputs and NU inputs, and W contains NW frequencies,
         %   the output H is a NY-by-NU-by-NW array such that H(:,:,k) gives
         %   the response at the frequency W(k).
         %
         %   If SYS is a S1-by-...-Sp array of systems with NY outputs and
         %   NU inputs, then SIZE(H)=[NY NU NW S1 ... Sp] where NW=LENGTH(W).
         %
         %   Note: FREQRESP is optimized for medium-to-large vectors of
         %   frequencies. Use EVALFR for a handful of frequencies.
         %
         %   See also DYNAMICSYSTEM/EVALFR, BODE, SIGMA, NYQUIST, NICHOLS, 
         %   DYNAMICSYSTEM.
         error(nargchk(2,2,nargin));
         if ~(isnumeric(w) && (isempty(w) || isvector(w)))
            ctrlMsgUtils.error('Control:analysis:freqresp1');
         end
         w = double(w(:));
         try
            [h,SingularWarn] = freqresp_(sys,w);
         catch E
            ltipack.throw(E,'command','freqresp',class(sys))
         end
         % Issue single warning if hit one or more singularities
         if SingularWarn
            ctrlMsgUtils.warning('Control:analysis:InfiniteFreqResp')
         end
      end      
      
      
      function s = allmargin(sys)
         %ALLMARGIN  All stability margins and crossover frequencies.
         %
         %   S = ALLMARGIN(SYS) provides detailed information about the
         %   gain, phase, and delay margins and the corresponding
         %   crossover frequencies of the SISO open-loop model SYS.
         %
         %   The output S is a structure with the following fields:
         %     * GMFrequency: all -180 deg crossover frequencies (in rad/sec)
         %     * GainMargin: corresponding gain margins (g.m. = 1/G where
         %       G is the gain at crossover)
         %     * PMFrequency: all 0 dB crossover frequencies (in rad/sec)
         %     * PhaseMargin: corresponding  phase margins (in degrees)
         %     * DelayMargin, DMFrequency: delay margins (in seconds for
         %       continuous-time systems, and multiples of the sample time for
         %       discrete-time systems) and corresponding critical frequencies
         %     * Stable: 1 if nominal closed loop is stable, 0 if unstable, and NaN
         %       if stability cannot be assessed (as in the case of most FRD systems)
         %
         %   S = ALLMARGIN(MAG,PHASE,W,TS) computes the stability margins from the
         %   frequency response data W, MAG, PHASE and the sampling time TS.
         %   ALLMARGIN expects frequency values W in rad/s, magnitude values MAG
         %   in linear scale, and phase values PHASE in degrees.  Interpolation is
         %   used between frequency points to approximate the true stability margins.
         %
         %   See also MARGIN, BODE, NYQUIST, NICHOLS, LTIVIEW, DYNAMICSYSTEM.
         if ~issiso(sys)
            ctrlMsgUtils.error('Control:analysis:margin1','allmargin');
         end
         
         % Compute margins and related frequencies
         try
            s = allmargin_(sys);
         catch E
            ltipack.throw(E,'command','allmargin',class(sys))
         end
      end
      
      function fb = bandwidth(sys,drop)
         %BANDWIDTH  Computes the frequency response bandwidth.
         %
         %   FB = BANDWIDTH(SYS) returns the bandwidth FB of the SISO  
         %   dynamic system SYS, defined as the first frequency where 
         %   the gain drops below 70.79 percent (-3 dB) of its DC value.
         %   The frequency FB is expressed in radians per second.
         %   For FRD models, BANDWIDTH uses the first frequency point to 
         %   approximate the DC gain.
         %
         %   FB = BANDWIDTH(SYS,DBDROP) further specifies the critical
         %   gain drop in dB.  The default value is -3 dB or a 70.79
         %   percent drop.
         %
         %   If SYS is an array of dynamic systems, BANDWIDTH returns an 
         %   array FB of the same size where FB(k) = BANDWIDTH(SYS(:,:,k)).
         %
         %   See also DCGAIN, ISSISO, DYNAMICSYSTEM.
         if ~issiso(sys)
            ctrlMsgUtils.error('Control:general:FirstArgSISOModel','bandwidth');
         elseif nargin==1
            drop = -3;  % -3dB by default (standard definition)
         elseif ~isreal(drop) || ~isscalar(drop) || drop>=0
            ctrlMsgUtils.error('Control:analysis:bandwidth1');
         end
         
         % Compute bandwidth
         try
            fb = bandwidth_(sys,drop);
         catch E
            ltipack.throw(E,'command','bandwidth',class(sys))
         end
         
         if any(isnan(fb(:)))
            ctrlMsgUtils.warning('Control:analysis:BandwidthNaN')
         end
      end
      
      function [n,fpeak] = norm(sys,type,tol)
         %NORM  Dynamic system norms.
         %
         %   NORM(SYS) is the root-mean-squares of the impulse response of
         %   the dynamic system SYS, or equivalently the H2 norm of SYS.
         %
         %   NORM(SYS,2) is the same as NORM(SYS).
         %
         %   NORM(SYS,inf) is the infinity norm of SYS, i.e., the peak gain
         %   of its frequency response (as measured by the largest singular
         %   value in the MIMO case).
         %
         %   NORM(SYS,inf,TOL) specifies a relative accuracy TOL for the
         %   computed infinity norm (TOL=1e-2 by default).
         %
         %   [NINF,FPEAK] = NORM(SYS,inf) also returns the frequency FPEAK
         %   where the gain achieves its peak value NINF.
         %
         %   If SYS is an array of dynamic systems, NORM returns an array 
         %   N of the same size where N(k) = NORM(SYS(:,:,k)).
         %
         %   See also SIGMA, FREQRESP, DYNAMICSYSTEM.
         
         %  Reference:
         %      Bruisma, N.A., and M. Steinbuch, "A Fast Algorithm to Compute
         %      the Hinfinity-Norm of a Transfer Function Matrix," Syst. Contr.
         %      Letters, 14 (1990), pp. 287-293.
         ni = nargin;
         error(nargchk(1,3,ni))
         if ni<2,
            type = 2;
         elseif strcmpi(type,'inf'),
            type = Inf;
         elseif ~(isequal(type,2) || isequal(type,Inf))
            ctrlMsgUtils.error('Control:analysis:norm1')
         end
         
         % Compute norm
         try
            switch type
               case 2
                  % H2 norm
                  n = normh2_(sys);    fpeak = [];
               case Inf
                  % Linf norm
                  if ni<3,
                     tol = 1e-2;
                  else
                     tol = max(100*eps,tol);
                  end
                  [n,fpeak] = norminf_(sys,tol);
            end
         catch E
            ltipack.throw(E,'command','norm',class(sys))
         end
      end
            
      function sys = ctranspose(sys)
         %CTRANSPOSE  Pertransposition of LTI models.
         %
         %   TSYS = CTRANSPOSE(SYS) is invoked by TSYS = SYS'.
         %
         %   For a continuous-time model SYS with transfer function H(s), 
         %   TSYS is the model with transfer function H(-s).'
         %
         %   For a discrete-time model SYS with transfer function H(z), 
         %   TSYS is the model with transfer function H(1/z).'
         %
         %   See also TRANSPOSE.
         try
            sys = ctranspose_(sys);
         catch E
            ltipack.throw(E,'expression','SYS''','SYS',class(sys))
         end
         sys.IOSize_ = sys.IOSize_([2 1]);
         sys = resetMetaData(sys);
      end
      
      function iopzmap(varargin)
         %IOPZMAP  Plots poles and zeros for each I/O pair of linear model.
         %
         %   IOPZMAP(SYS) computes and plots the poles and zeros of each input/output
         %   pair of the LTI model SYS.  The poles are plotted as x's and the zeros are
         %   plotted as o's.
         %
         %   IOPZMAP(SYS1,SYS2,...) shows the poles and zeros of multiple LTI models
         %   SYS1,SYS2,... on a single plot.  You can specify distinctive colors for
         %   each model, as in  iopzmap(sys1,'r',sys2,'y',sys3,'g')
         %
         %   The functions SGRID or ZGRID can be used to plot lines of constant
         %   damping ratio and natural frequency in the s or z plane.
         %
         %   For arrays SYS of LTI models, IOPZMAP plots the poles and zeros of
         %   each model in the array on the same diagram.
         %
         %   For additional graphical options for pole/zero plots, see IOPZPLOT.
         %
         %   See also IOPZPLOT, PZMAP, POLE, ZERO, SGRID, ZGRID, RLOCUS.
         ni = nargin;
         for ct = ni:-1:1
            ArgNames(ct,1) = {inputname(ct)};
         end
         % Assign vargargin names to systems if systems do not have a name
         varargin = argname2sysname(varargin,ArgNames);
         try
            iopzplot(varargin{:});
         catch ME
            throw(ME)
         end
      end
      
      function sys = interp(sys,w)
         %INTERP  Interpolates FRD model between frequency points.
         %
         %   ISYS = INTERP(SYS,FREQS) interpolates the frequency response
         %   data contained in the FRD model SYS at the frequencies FREQS.
         %   INTERP uses linear interpolation and returns an FRD model ISYS
         %   containing the interpolated data at the new frequencies FREQS.
         %
         %   The frequency values FREQS should be expressed in the same
         %   units as SYS.FREQUENCY and lie between the smallest and largest
         %   frequency points in SYS (extrapolation is not supported).
         %
         %   See also FREQRESP, DYNAMICSYSTEM.
         if ~isa(sys,'FRDModel')
            % Needed because of INTERP in Signal
            ctrlMsgUtils.error('Control:general:NotSupportedModelsofClass','interp',class(sys))
         end
         try
            w = sort(ltipack.utCheckFRDData(w,'f'));
            sys = interp_(sys,w);
         catch E
            ltipack.throw(E,'command','interp',class(sys))
         end
      end
      
      function M = genmat(~) %#ok<*STOUT>
         %GENMAT  Converts static model to generalized matrix type.
         %
         %   See also STATICMODEL/GENMAT.
         ctrlMsgUtils.error('Control:lftmodel:genmat1')
      end
      
      function M = umat(~)
         %UMAT  Converts static model to uncertain matrix.
         %
         %   See also STATICMODEL/UMAT.
         ctrlMsgUtils.error('Robust:umodel:umat1')
      end
      
      function sys = inv(sys)
         %INV  Computes the inverse of a dynamic system.
         %
         %   See also INPUTOUTPUTMODEL/INV.
         try
            sys = inv@InputOutputModel(sys);
         catch ME
            throw(ME)
         end
         % Metadata
         if ~isempty(sys.Name_)
            sys.Name = sprintf('inv(%s)',sys.Name_);
         end
         sys.Notes_ = [];  sys.UserData = [];
         % Swap I/O names and  I/O groups
         [sys.InputName_,sys.OutputName_] = deal(sys.OutputName_,sys.InputName_);
         [sys.InputUnit_,sys.OutputUnit_] = deal(sys.OutputUnit_,sys.InputUnit_);
         [sys.InputGroup_,sys.OutputGroup_] = deal(sys.OutputGroup_,sys.InputGroup_);
      end
      
      function sys = mpower(sys,k)
         %MPOWER  Repeated products of dynamic system.
         %
         %   See also INPUTOUTPUTMODEL/MPOWER.
         try
            sys = mpower@InputOutputModel(sys,k);
         catch ME
            throw(ME)
         end
         % Metadata
         if k<0
            % Swap I/O names and  I/O groups
            [sys.InputName_,sys.OutputName_] = deal(sys.OutputName_,sys.InputName_);
            [sys.InputUnit_,sys.OutputUnit_] = deal(sys.OutputUnit_,sys.InputUnit_);
            [sys.InputGroup_,sys.OutputGroup_] = deal(sys.OutputGroup_,sys.InputGroup_);
         end
         sys.Name_ = [];  sys.Notes_ = [];  sys.UserData = [];
      end
      
      %-----------------------------------------------------------
      %    PUBLIC GET/SET API
      %-----------------------------------------------------------
      
      function Value = get.TimeUnit(sys)
         % GET function for TimeUnit property
         Value = sys.TimeUnit_;
         if isempty(Value)
            Value = '';  % default
         end
      end
      
      function sys = set.TimeUnit(sys,Value)
         % SET function for TimeUnit property
         if isempty(Value)
            sys.TimeUnit_ = [];
         else
            TU = ltipack.matchKey(Value,{'nanoseconds','microseconds','milliseconds',...
               'seconds','minutes','hours','days','weeks','months','years'});
            if isempty(TU)
               ctrlMsgUtils.error('Control:ltiobject:setTimeUnit')
            end
            sys.TimeUnit_ = TU;
         end
      end
      
      function Value = get.InputName(sys)
         % GET function for InputName property
         Value = getInputName_(sys);
      end
      
      function Value = get.OutputName(sys)
         % GET function for OutputName property
         Value = getOutputName_(sys);
      end
      
      function sys = set.InputName(sys,Value)
         % SET function for InputName property
         if isempty(Value)
            % Interpret as clearing the input names
            sys.InputName_ = [];
         else
            sys.InputName_ = localCompress(ChannelNameCheck(Value,'InputName'));
            if sys.CrossValidation_
               sys = checkInputConsistency(sys);
            end
         end
      end
      
      function sys = set.OutputName(sys,Value)
         % SET function for OutputName property
         if isempty(Value)
            sys.OutputName_ = [];
         else
            sys.OutputName_ = localCompress(ChannelNameCheck(Value,'OutputName'));
            if sys.CrossValidation_
               sys = checkOutputConsistency(sys);
            end
         end
      end
      
      function Value = get.InputUnit(sys)
         % GET function for InputUnit property
         Value = ltipack.fullstring(sys.InputUnit_,sys.IOSize_(2));
      end
      
      function Value = get.OutputUnit(sys)
         % GET function for OutputUnit property
         Value = ltipack.fullstring(sys.OutputUnit_,sys.IOSize_(1));
      end
      
      function sys = set.InputUnit(sys,Value)
         % SET function for InputUnit property
         if isempty(Value)
            sys.InputUnit_ = [];
         else
            sys.InputUnit_ = localCompress(ChannelUnitCheck(Value,'InputUnit'));
            if sys.CrossValidation_
               sys = checkInputConsistency(sys);
            end
         end
      end
      
      function sys = set.OutputUnit(sys,Value)
         % SET function for OutputUnit property
         if isempty(Value)
            sys.OutputUnit_ = [];
         else
            sys.OutputUnit_ = localCompress(ChannelUnitCheck(Value,'OutputUnit'));
            if sys.CrossValidation_
               sys = checkOutputConsistency(sys);
            end
         end
      end
      
      function Value = get.InputGroup(sys)
         % GET function for InputGroup property
         Value = sys.InputGroup_;
      end
      
      function Value = get.OutputGroup(sys)
         % GET function for OutputGroup property
         Value = sys.OutputGroup_;
      end
      
      function sys = set.InputGroup(sys,Value)
         % SET function for InputGroup property
         if isempty(Value)
            Value = struct;
         elseif isstruct(Value)
            % Remove empty groups
            Value = localRemoveEmptyGroups(Value);
         end
         sys.InputGroup_ = Value;
         if sys.CrossValidation_
            sys = checkInputGroup(sys);
         end
      end
      
      function sys = set.OutputGroup(sys,Value)
         % SET function for OutputGroup property
         if isempty(Value)
            Value = struct;
         elseif isstruct(Value)
            % Remove empty groups
            Value = localRemoveEmptyGroups(Value);
         end
         sys.OutputGroup_ = Value;
         if sys.CrossValidation_
            sys = checkOutputGroup(sys);
         end
      end
      
      function Value = get.Name(sys)
         % GET function for Name property
         Value = sys.Name_;
         if isempty(Value)
            Value = '';   % default
         end
      end
      
      function sys = set.Name(sys,Value)
         % SET function for Name property
         sys = setName_(sys,Value);
      end
      
      function Value = get.Notes(sys)
         % GET function for Notes property
         Value = sys.Notes_;
         if isempty(Value)
            Value = {};   % default
         end
      end
      
      function sys = set.Notes(sys,Value)
         % SET function for Notes property
         if isempty(Value)
            sys.Notes_ = [];
         else
            if ischar(Value),
               Value = {Value};
            elseif iscellstr(Value)
               Value = Value(:);
            else
               ctrlMsgUtils.error('Control:ltiobject:setLTI2','Notes')
            end
            sys.Notes_ = Value;
         end
      end
      
   end
      
   %% BINARY OPERATION SUPPORT
   methods (Access = protected)
      
      %------------
      function sys = copyVariable(~,sys)
         % Default implementation: no-op
      end
      
      %------------
      function sys = copyMetaData(refsys,sys)
         % Fast data copy from one object to another
         sys.TimeUnit_ = refsys.TimeUnit_;
         sys.InputName_ = refsys.InputName_;
         sys.OutputName_ = refsys.OutputName_;
         sys.InputUnit_ = refsys.InputUnit_;
         sys.OutputUnit_ = refsys.OutputUnit_;
         sys.InputGroup_ = refsys.InputGroup_;
         sys.OutputGroup_ = refsys.OutputGroup_;
         sys.Name_ = refsys.Name_;
         sys.Notes_ = refsys.Notes_;
         sys.UserData = refsys.UserData;
      end

      %------------
      function sys = resetMetaData(sys)
         % Restores default values except for TimeUnit
         sys.InputName_ = [];  sys.OutputName_ = [];
         sys.InputUnit_ = [];  sys.OutputUnit_ = [];
         sys.InputGroup_ = struct;  sys.OutputGroup_ = struct;
         sys.Name_ = [];  sys.Notes_ = [];  sys.UserData = [];
      end
     
      %------------
      function sys1 = iocatMetaData(dim,sys1,sys2)
         % Metadata management in HORZCAT/VERTCAT/APPEND
         sys1.TimeUnit_ = DynamicSystem.resolveTimeUnit(sys1.TimeUnit_,sys2.TimeUnit_);
         if any(dim==1)
            sys1 = catOutput(sys1,sys2);
         else
            sys1 = plusOutput(sys1,sys2);
         end
         if any(dim==2)
            sys1 = catInput(sys1,sys2);
         else
            sys1 = plusInput(sys1,sys2);
         end
         sys1.Name_ = [];  sys1.Notes_ = [];  sys1.UserData = [];
      end
      
      %------------
      function sys1 = plusMetaData(sys1,sys2)
         % Metadata management in PLUS
         sys1.TimeUnit_ = DynamicSystem.resolveTimeUnit(sys1.TimeUnit_,sys2.TimeUnit_);
         sys1 = plusInput(sys1,sys2);
         sys1 = plusOutput(sys1,sys2);
         sys1.Name_ = [];  sys1.Notes_ = [];  sys1.UserData = [];
      end
      
      %------------
      function sys1 = mtimesMetaData(sys1,sys2,ScalarFlags)
         % Metadata management in MTIMES
         sys1.TimeUnit_ = DynamicSystem.resolveTimeUnit(sys1.TimeUnit_,sys2.TimeUnit_);
         if ScalarFlags(1)
            % Scalar multiplication: keep SYS2's metadata if SYS1 is scalar
            sys1 = copyMetaData(sys2,sys1);
         elseif ~ScalarFlags(2)
            sys1.InputName_ = sys2.InputName_;
            sys1.InputUnit_ = sys2.InputUnit_;
            sys1.InputGroup_ = sys2.InputGroup_;
            sys1.Name_ = [];  sys1.Notes_ = [];  sys1.UserData = [];
         end
      end
            
      %------------
      function sys1 = feedbackMetaData(sys1,sys2)
         % Metadata management in FEEDBACK
         sys1.TimeUnit_ = DynamicSystem.resolveTimeUnit(sys1.TimeUnit_,sys2.TimeUnit_);
         sys1.Name_ = [];  sys1.Notes_ = [];  sys1.UserData = [];
      end
      
      %------------
      function sys1 = lftMetaData(sys1,sys2,indu1,indy1,indu2,indy2)
         % Metadata management in LFT
         [ny1,nu1] = iosize(sys1);
         [ny2,nu2] = iosize(sys2);
         indw1 = 1:nu1; indw1(indu1) = [];  nw1 = length(indw1);
         indz1 = 1:ny1; indz1(indy1) = [];  nz1 = length(indz1);
         indw2 = 1:nu2; indw2(indu2) = [];  nw2 = length(indw2);
         indz2 = 1:ny2; indz2(indy2) = [];  nz2 = length(indz2);
         
         % I/O names/units
         if ~(isempty(sys1.InputName_) && isempty(sys2.InputName_))
            In1 = ltipack.fullstring(sys1.InputName_,nu1);
            In2 = ltipack.fullstring(sys2.InputName_,nu2);
            sys1.InputName_ = localCompress([In1(indw1,:) ; In2(indw2,:)]); % could be all empty!
         end
         if ~(isempty(sys1.InputUnit_) && isempty(sys2.InputUnit_))
            In1 = ltipack.fullstring(sys1.InputUnit_,nu1);
            In2 = ltipack.fullstring(sys2.InputUnit_,nu2);
            sys1.InputUnit_ = localCompress([In1(indw1,:) ; In2(indw2,:)]);
         end
         if ~(isempty(sys1.OutputName_) && isempty(sys2.OutputName_))
            Out1 = ltipack.fullstring(sys1.OutputName_,ny1);
            Out2 = ltipack.fullstring(sys2.OutputName_,ny2);
            sys1.OutputName_ = localCompress([Out1(indz1,:) ; Out2(indz2,:)]);
         end
         if ~(isempty(sys1.OutputUnit_) && isempty(sys2.OutputUnit_))
            Out1 = ltipack.fullstring(sys1.OutputUnit_,ny1);
            Out2 = ltipack.fullstring(sys2.OutputUnit_,ny2);
            sys1.OutputUnit_ = localCompress([Out1(indz1,:) ; Out2(indz2,:)]);
         end
         
         % I/O groups
         sys1.InputGroup_ = groupcat(...
            groupref(sys1.InputGroup_,indw1),...
            groupref(sys2.InputGroup_,indw2),nw1+1:nw1+nw2);
         sys1.OutputGroup_ = groupcat(...
            groupref(sys1.OutputGroup_,indz1),...
            groupref(sys2.OutputGroup_,indz2),nz1+1:nz1+nz2);
         
         sys1.TimeUnit_ = DynamicSystem.resolveTimeUnit(sys1.TimeUnit_,sys2.TimeUnit_);
         sys1.Name_ = [];  sys1.Notes_ = [];  sys1.UserData = [];
      end
      
      %------------
      function sys = subsysMetaData(sys,indrow,indcol)
         % Metadata management in I/O selection operation SYS(indrow,indcol)
         sys.Notes_ = [];
         sys.UserData = [];
         
         % Check for duplicated I/O names
         if isDuplicated(sys.OutputName_,indrow) || ...
               isDuplicated(sys.InputName_,indcol)
            ctrlMsgUtils.warning('Control:ltiobject:DuplicatedIONames')
         end
         
         % Set input names, units, and groups
         if ~isempty(sys.InputName_)
            sys.InputName_ = localCompress(sys.InputName_(indcol,1));
         end
         if ~isempty(sys.InputUnit_)
            sys.InputUnit_ = localCompress(sys.InputUnit_(indcol,1));
         end
         sys.InputGroup_ = groupref(sys.InputGroup_,indcol);
         
         % Set output names, units, and groups
         if ~isempty(sys.OutputName_)
            sys.OutputName_ = localCompress(sys.OutputName_(indrow,1));
         end
         if ~isempty(sys.OutputUnit_)
            sys.OutputUnit_ = localCompress(sys.OutputUnit_(indrow,1));
         end
         sys.OutputGroup_ = groupref(sys.OutputGroup_,indrow);
      end
      
      %-------------------------------------------------
      function sys = plusInput(sys,sys2)
         % Manages input channel metadata in plus-like operations
         % I/O channel names/units should match
         [sys.InputName_,clash] = ltipack.mrgname(sys.InputName_,sys2.InputName_);
         if clash,
            ctrlMsgUtils.warning('Control:combination:InputNameClash')
            sys.InputName_ = [];
         end
         [sys.InputUnit_,clash] = ltipack.mrgname(sys.InputUnit_,sys2.InputUnit_);
         if clash,
            ctrlMsgUtils.warning('Control:combination:InputUnitClash')
            sys.InputUnit_ = [];
         end
         % I/O groups should match
         [sys.InputGroup_,clash] = mrggroup(sys.InputGroup_,sys2.InputGroup_);
         if clash,
            ctrlMsgUtils.warning('Control:combination:InputGroupClash')
            sys.InputGroup_ = struct;
         end
      end
      
      function sys = plusOutput(sys,sys2)
         % Manages output channel metadata in plus-like operations
         [sys.OutputName_,clash] = ltipack.mrgname(sys.OutputName_,sys2.OutputName_);
         if clash,
            ctrlMsgUtils.warning('Control:combination:OutputNameClash')
            sys.OutputName_ = [];
         end
         [sys.OutputUnit_,clash] = ltipack.mrgname(sys.OutputUnit_,sys2.OutputUnit_);
         if clash,
            ctrlMsgUtils.warning('Control:combination:OutputUnitClash')
            sys.OutputUnit_ = [];
         end
         [sys.OutputGroup_,clash] = mrggroup(sys.OutputGroup_,sys2.OutputGroup_);
         if clash,
            ctrlMsgUtils.warning('Control:combination:OutputGroupClash')
            sys.OutputGroup_ = struct;
         end
      end
      
      %-------------------------------------------------
      function sys = catInput(sys,sys2)
         % Manages input channel metadata in concatenation operations
         nu = sys.IOSize_(2);   nu2 = sys2.IOSize_(2);
         % InputName
         if ~(isempty(sys.InputName_) && isempty(sys2.InputName_))
            sys.InputName_ = [ltipack.fullstring(sys.InputName_,nu) ; ltipack.fullstring(sys2.InputName_,nu2)];
         end
         % InputUnit
         if ~(isempty(sys.InputUnit_) && isempty(sys2.InputUnit_))
            sys.InputUnit_ = [ltipack.fullstring(sys.InputUnit_,nu) ; ltipack.fullstring(sys2.InputUnit_,nu2)];
         end
         % InputGroup
         sys.InputGroup_ = groupcat(sys.InputGroup_,sys2.InputGroup_,nu+1:nu+nu2);
      end
      
      function sys = catOutput(sys,sys2)
         % Manages output channel metadata in concatenation operations
         ny = sys.IOSize_(1);   ny2 = sys2.IOSize_(1);
         % OutputName
         if ~(isempty(sys.OutputName_) && isempty(sys2.OutputName_))
            sys.OutputName_ = [ltipack.fullstring(sys.OutputName_,ny) ; ltipack.fullstring(sys2.OutputName_,ny2)];
         end
         % OutputUnit
         if ~(isempty(sys.OutputUnit_) && isempty(sys2.OutputUnit_))
            sys.OutputUnit_ = [ltipack.fullstring(sys.OutputUnit_,ny) ; ltipack.fullstring(sys2.OutputUnit_,ny2)];
         end
         % OutputGroup
         sys.OutputGroup_ = groupcat(sys.OutputGroup_,sys2.OutputGroup_,ny+1:ny+ny2);
      end
      
      %------------
      function sys = augmentOutput(sys,OutNames,OutUnits,GroupName)
         % Adds set of channels to existing output channels
         ny = sys.IOSize_(1);
         ny2 = length(OutNames);
         
         % Add output group for newchannels
         if nargin>3
            if iscell(sys.OutputGroup_)
               Group = {1:ny2 , GroupName};
            else
               Group = struct(GroupName,1:ny2);
            end
            sys.OutputGroup_ = groupcat(sys.OutputGroup_,Group,ny+1:ny+ny2);
         end
         
         % Append new channels to output names/units
         OutNames = [sys.OutputName ; OutNames];
         if all(strcmp(OutNames,''))
            sys.OutputName_ = [];
         else
            sys.OutputName_ = OutNames;
         end
         OutUnits = [sys.OutputUnit ; OutUnits];
         if all(strcmp(OutUnits,''))
            sys.OutputUnit_ = [];
         else
            sys.OutputUnit_ = OutUnits;
         end
      end
      
      %------------
      function sys = reload(sys,s)
         % Restore metadata when loading object
         % REVISIT: Delete this after @dynamicsys is removed
         s = struct(s);
         % END REVISIT
         sys.IOSize_ = [length(s.OutputName),length(s.InputName)];
         if ~all(strcmp(s.InputName,''))
            sys.InputName_ = s.InputName;
         end
         if ~all(strcmp(s.OutputName,''))
            sys.OutputName_ = s.OutputName;
         end
         sys.InputGroup_ = s.InputGroup;
         sys.OutputGroup_ = s.OutputGroup;
         if ~isempty(s.Name)
            sys.Name_ = s.Name;
         end
         if ~isempty(s.Notes)
            sys.Notes_ = s.Notes;
         end
         sys.UserData = s.UserData;
      end
      
   end
   
   
   %% PROTECTED METHODS
   methods (Access = protected)
      
      dispGroup(sys)
      sys = indexasgn(sys,indices,rhs)
      
      function Value = getInputName_(sys)
         % Can be overloaded to adjust default names
         Value = ltipack.fullstring(sys.InputName_,sys.IOSize_(2));
      end
      
      function Value = getOutputName_(sys)
         Value = ltipack.fullstring(sys.OutputName_,sys.IOSize_(1));
      end
      
      function sys = setName_(sys,Value)
         % Can be overloaded to impose additional restrictions on Name
         if isempty(Value)
            sys.Name_ = [];
         elseif ischar(Value)
            sys.Name_ = Value;
         else
            ctrlMsgUtils.error('Control:ltiobject:setLTI2','Name')
         end
      end
      
      %--------------------------
      function sys = checkConsistency(sys)
         % Cross-validation of system meta data
         sys = checkDataConsistency(sys);  % sets IOSize_ based on data
         
         % Check InputName and OutputName are consistent with IOSize_.
         % Resize if necessary, but only when all names are blank. 
         % Otherwise
         %     sys = ss(1,2,3,4); set(sys,'inputn',{'a','b'})
         % would not error out.
         sys = checkInputConsistency(sys);
         sys = checkOutputConsistency(sys);
         
         % Check InputGroup and OutputGroup
         sys = checkInputGroup(sys);
         sys = checkOutputGroup(sys);
      end
      
      %--------------------------
      function indices = name2index(sys,indstr,ioflag)
         % Turn references by name into regular subscripts
         %
         %   IND = NAME2INDEX(SYS,STRCELL,IOFLAG) takes a string
         %   vector STRCELL and looks for matching I/O channel or
         %   I/O group names in the system SYS.  The search is
         %   carried out among the outputs if IOFLAG=1, and among
         %   the inputs if IOFLAG=2.
         if isnumeric(indstr) || islogical(indstr) || (ischar(indstr) && strcmp(indstr,':'))
            indices = indstr;   return
         end
         
         % Make sure input is a cell array of strings
         if ischar(indstr)
            indstr = cellstr(indstr);
         elseif ~iscellstr(indstr)
            ctrlMsgUtils.error('Control:ltiobject:subsref1',ioflag)
         end
         if ~isvector(indstr)
            ctrlMsgUtils.error('Control:ltiobject:subsref6')
         end
         
         % Set name lists for search based on IOFLAG
         if ioflag==1
            ChannelNames = sys.OutputName;
            Groups = getgroup(sys.OutputGroup);
         else
            ChannelNames = sys.InputName;
            Groups = getgroup(sys.InputGroup);
         end
         GroupNames = fieldnames(Groups);
         
         % Perform a string-by-string matching to respect the
         % referencing order
         indices = zeros(1,0);
         nu = length(ChannelNames);
         for ix = 1:length(indstr)
            str = indstr{ix};
            if isempty(str),
               ctrlMsgUtils.error('Control:ltiobject:subsref7',str)
            end
            % Match against channel names and group names
            imatch = localFindMatch(str,[ChannelNames;GroupNames]);
            imatch1 = imatch(imatch<=nu);     % Channel name matches
            imatch2 = imatch(imatch>nu)-nu;   % Group name matches
            nhits1 = length(imatch1);
            nhits2 = length(imatch2);
            % Error checks
            if ~nhits1 && ~nhits2,
               ctrlMsgUtils.error('Control:ltiobject:subsref7',str)
            elseif nhits1 && nhits2,
               ctrlMsgUtils.error('Control:ltiobject:subsref8',str)
            elseif nhits2,
               % Group match
               if nhits2>1,
                  ctrlMsgUtils.warning('Control:ltiobject:MultipleGroupMatch',str)
               end
               for ct=1:length(imatch2)
                  indices = [indices , Groups.(GroupNames{imatch2(ct)})]; %#ok<AGROW>
               end
            else
               % Channel match
               if nhits1>1,
                  ctrlMsgUtils.warning('Control:ltiobject:MultipleChannelMatch',str)
               end
               indices = [indices , imatch1(:)']; %#ok<AGROW>
            end
         end
      end
      
   end
      
   
   %% HIDDEN METHODS
   methods(Hidden)
      
      [InputNames,OutputNames,EmptySys] = mrgios(varargin)
      
      function n = numsys(sys)
         % Number of models in dynamic system array.
         % Deprecated, replaced by nmodels.
         n = prod(getArraySize(sys));
      end
      
      function sys = iorep(sys,s)
         % Standardized I/O replication function
         sys = repsys(sys,s);
      end
      
      function sys = star(varargin)
         %STAR  Redheffer star product of LTI systems (obsolete, see LFT).
         sys = lft(varargin{:});
      end
      
      function Name = getName(sys)
         % Fast, subsref-free access to Name (needed for Control Design blocks)
         Name = sys.Name_;
      end
      
      function [InputName,OutputName] = getIOName(sys)
         % Used for named-based IC support in PARALLEL,...
         InputName = sys.InputName_;
         OutputName = sys.OutputName_;
      end
      
      function sys = transferInputOutput_(sys,rhs,iy,iu)
         % Transfers I/O names, units, and groups from RHS to SYS starting
         % at the I/O channels IU and IY. Used by GETLFTMODEL and LFTDATA
         [ny,nu] = iosize(rhs);
         sys.InputName(iu+1:iu+nu,:) = rhs.InputName;
         sys.InputUnit(iu+1:iu+nu,:) = rhs.InputUnit;
         sys.InputGroup = groupcat(struct,rhs.InputGroup,iu+1:iu+nu);
         sys.OutputName(iy+1:iy+ny,:) = rhs.OutputName;
         sys.OutputUnit(iy+1:iy+ny,:) = rhs.OutputUnit;
         sys.OutputGroup = groupcat(struct,rhs.OutputGroup,iy+1:iy+ny);
      end
      
      function PIDTuningData = getPIDTuningData(G,Type,NUP,index) %#ok<*INUSD>
         %GETPIDTUNINGDATA returns ltipack.PIDTuningData object that
         %implements RRT tuning method.  It serves as an interface to the
         %PID tuning API/GUI tools.  To support PID tuning for any
         %DynamicSystem subclass, overload this method in the subclass.
         %See examples in @tf and @ss for details.
         ctrlMsgUtils.error('Control:ltiobject:GetPIDTuningData',class(G))
      end
            
   end
   
   %% PRIVATE METHODS
   methods (Access = private)
      
      %-----------------------------------------------------------
      function sys = checkInputConsistency(sys)
         % Checks InputName/InputUnit consistency with input size
         nu = sys.IOSize_(2);
         if ~(isempty(sys.InputName_) || length(sys.InputName_)==nu)
            if all(strcmp(sys.InputName_,''))
               % To support I/O resizing through SET operations
               sys.InputName_ = [];
            else
               ctrlMsgUtils.error('Control:ltiobject:ltiProperties05')
            end
         end
         if ~(isempty(sys.InputUnit_) || length(sys.InputUnit_)==nu)
            if all(strcmp(sys.InputUnit_,''))
               sys.InputUnit_ = [];
            else
               ctrlMsgUtils.error('Control:ltiobject:ltiProperties15')
            end
         end
      end
      
      %-----------------------------------------------------------
      function sys = checkOutputConsistency(sys)
         % Checks OutputName/OutputUnit consistency with output size
         ny = sys.IOSize_(1);
         if ~(isempty(sys.OutputName_) || length(sys.OutputName_)==ny)
            if all(strcmp(sys.OutputName_,''))
               sys.OutputName_ = [];
            else
               ctrlMsgUtils.error('Control:ltiobject:ltiProperties06')
            end
         end
         if ~(isempty(sys.OutputUnit_) || length(sys.OutputUnit_)==ny)
            if all(strcmp(sys.OutputUnit_,''))
               sys.OutputUnit_ = [];
            else
               ctrlMsgUtils.error('Control:ltiobject:ltiProperties16')
            end
         end
      end
      
      %-----------------------------------------------------------
      function sys = checkInputGroup(sys)
         % Checks InputGroup consistency
         try
            iGroups = getgroup(sys.InputGroup_);
         catch %#ok<CTCH>
            iGroups = [];
         end
         if ~isa(iGroups,'struct') || ~isequal(size(iGroups),[1 1])
            ctrlMsgUtils.error('Control:ltiobject:ltiProperties07')
         end
         f = fieldnames(iGroups);
         Nu = sys.IOSize_(2);
         for ct=1:length(f)
            channels = iGroups.(f{ct});
            if ~isnumeric(channels) || ~isvector(channels) || ...
                  isempty(channels) || size(channels,1)~=1 || ...
                  ~isequal(channels,round(channels))
               ctrlMsgUtils.error('Control:ltiobject:ltiProperties08')
            elseif any(channels<1) || any(channels>Nu),
               ctrlMsgUtils.error('Control:ltiobject:ltiProperties09')
            elseif length(unique(channels))<length(channels)
               ctrlMsgUtils.error('Control:ltiobject:ltiProperties10')
            end
         end
      end
      
      %-----------------------------------------------------------
      function sys = checkOutputGroup(sys)
         % Checks OutputGroup consistency
         try
            oGroups = getgroup(sys.OutputGroup_);
         catch %#ok<CTCH>
            oGroups = [];
         end
         if ~isa(oGroups,'struct') || ~isequal(size(oGroups),[1 1])
            ctrlMsgUtils.error('Control:ltiobject:ltiProperties11')
         end
         f = fieldnames(oGroups);
         Ny = sys.IOSize_(1);
         for ct=1:length(f)
            channels = oGroups.(f{ct});
            if ~isnumeric(channels) || ~isvector(channels) || ...
                  isempty(channels) || size(channels,1)~=1 || ...
                  ~isequal(channels,round(channels))
               ctrlMsgUtils.error('Control:ltiobject:ltiProperties12')
            elseif any(channels<1) || any(channels>Ny),
               ctrlMsgUtils.error('Control:ltiobject:ltiProperties13')
            elseif length(unique(channels))<length(channels)
               ctrlMsgUtils.error('Control:ltiobject:ltiProperties14')
            end
         end
      end
      
   end
   
   %% STATIC METHODS
   methods(Static, Access=protected)
      
      % Input parsing
      [sysList,Extras,Options] = parseRespFcnInputs(InputList,InputNames)
      % Input checking
      [sysList,w] = checkBodeInputs(sysList,Extras)
      [sysList,w,type] = checkSigmaInputs(sysList,Extras)
      [sysList,t] = checkStepInputs(sysList,Extras)
      [sysList,t,x0] = checkInitialInputs(sysList,Extras)
      [sysList,t,x0,u,InterpRule] = checkLsimInputs(sysList,Extras)
      sysList = checkPZInputs(sysList,Extras)
      [sysList,k] = checkRootLocusInputs(sysList,Extras)
      
      function TU = resolveTimeUnit(TU,TU2)
         % Resolves TimeUnit in binary operations
         if ~isempty(TU2)
            if isempty(TU)
               TU = TU2;
            elseif ~strcmp(TU,TU2)
               ctrlMsgUtils.error('Control:combination:TimeUnitMismatch')
            end
         end
      end
      
   end
end

%-------------------- LOCAL FUNCTIONS -------------------------------


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = ChannelNameCheck(a,PropName)
% Checks specified I/O names

% Determine if first argument is an array or cell vector
% of single-line strings.
if ischar(a) && ndims(a)==2,
   % A is a 2D array of padded strings
   a = cellstr(a);
elseif iscellstr(a) && isvector(a)
   % A is a cell vector of strings. Check that each entry
   % is a single-line string
   a = a(:);
   if any(cellfun(@ndims,a)>2) || any(cellfun(@(x) size(x,1),a)>1),
      ctrlMsgUtils.error('Control:ltiobject:setLTI3',PropName)
   end
else
   ctrlMsgUtils.error('Control:ltiobject:setLTI3',PropName)
end

% Check that nonempty I/O names are unique
as = sort(strtrim(a));
repeat = strcmp(as(1:end-1),as(2:end)) & ~strcmp(as(1:end-1),'');
if any(repeat)
   ctrlMsgUtils.warning('Control:ltiobject:RepeatedChannelNames')
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = ChannelUnitCheck(a,PropName)
% Checks specified I/O units
if ischar(a)
   a = {a};
end
if iscellstr(a) && isvector(a)
   % A is a cell vector of strings. Check that each entry is a single-line string
   a = a(:);
   if any(cellfun(@ndims,a)>2) || any(cellfun(@(x) size(x,1),a)>1),
      ctrlMsgUtils.error('Control:ltiobject:setLTI6',PropName)
   end
else
   ctrlMsgUtils.error('Control:ltiobject:setLTI6',PropName)
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g = localRemoveEmptyGroups(g)
% Removes groups with empty channel sets (simplifies group
% creation in functions like LQGTRACK)
ie = structfun(@isempty,g);
if any(ie)
   f = fieldnames(g);
   g = rmfield(g,f(ie));
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function boo = isDuplicated(Names,Indices)
% Checks for I/O name duplications as in sys(:,[1 1])
if ~isempty(Names) && isnumeric(Indices)
   Indices = sort(Indices);
   boo = ~all(cellfun(@isempty,Names(Indices(diff(Indices)==0))));
else
   boo = false;
end
end

%%%%%%%%%%%%%%%%%%
function imatch = localFindMatch(str,names)
% Find all NAMES matching STR using a cascade of matching filters
nchar = length(str);

% 1) Start with partial context-insensitive matches
imatch = find(strncmpi(str,names,nchar));

% 2) Use case-sensitive partial matching to further narrow hits
if length(imatch)>1
   icsm = find(strncmp(str,names(imatch),nchar));
   if ~isempty(icsm)
      imatch = imatch(icsm);
   end
end

% 3) Look for exact match if there are still multiple hits
if length(imatch)>1
   iexact = find(cellfun('length',names(imatch))==nchar);
   if ~isempty(iexact)
      imatch = imatch(iexact);
   end
end
end

%%%%%%
function s = localCompress(s)
% Do not store all-undefined names
if all(strcmp(s,''))
   s = [];
end
end
