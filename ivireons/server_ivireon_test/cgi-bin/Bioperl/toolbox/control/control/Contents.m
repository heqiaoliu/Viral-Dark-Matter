% Control System Toolbox
% Version 9.0 (R2010b) 03-Aug-2010
%
% General.
%   ctrlpref       - Set Control System Toolbox preferences.
%   InputOutputModel - Overview of input/output model objects.
%   DynamicSystem  - Overview of dynamic system objects.
%   lti            - Overview of linear time-invariant system objects.
%
% Graphical User Interfaces.
%   ltiview        - LTI Viewer (time and frequency response analysis).
%   sisotool       - SISO Design Tool (interactive compensator tuning).
%   pidtool        - PID Design Tool (interactive PID controller tuning).
%   sisoinit       - Configure the SISO Design Tool at startup.
%
% Creating linear models.
%   tf             - Create transfer function (TF) models.
%   zpk            - Create zero/pole/gain (ZPK) models.
%   ss             - Create state-space (SS) models.
%   dss            - Create descriptor state-space models.
%   delayss        - Create state-space models with delayed terms.
%   frd            - Create frequency response data (FRD) models.
%   pid            - Create PID controller in parallel form.
%   pidstd         - Create PID controller in standard form.
%   tf/exp         - Create pure continuous-time delays (TF and ZPK only)
%   filt           - Specify digital filters.
%   InputOutputModel/set - Set/modify properties of model object.
%   setDelayModel  - Specify internal delay model (state space only).
%   
% Data extraction.
%   tfdata         - Extract numerators and denominators.
%   zpkdata        - Extract zero/pole/gain data.
%   ssdata         - Extract state-space matrices.
%   dssdata        - Descriptor version of SSDATA.
%   frdata         - Extract frequency response data.
%   piddata        - Extract PID parameters in parallel form.
%   pidstddata     - Extract PID parameters in standard form.
%   InputOutputModel/get - Access properties of model object.
%   ss/getDelayModel - Access internal delay model (state space only).
%
% Conversions.
%   tf             - Conversion to transfer function.
%   zpk            - Conversion to zero/pole/gain.
%   ss             - Conversion to state space.
%   frd            - Conversion to frequency data.
%   pid            - Conversion to PID controller in parallel form.
%   pidstd         - Conversion to PID controller in standard form.
%   c2d            - Continuous to discrete conversion.
%   d2c            - Discrete to continuous conversion.
%   d2d            - Resample discrete-time model.
%   upsample       - Upsample discrete-time systems
%
% System interconnections.
%   append         - Aggregate models by appending inputs and outputs.
%   parallel       - Connect models in parallel (see also overloaded +).
%   series         - Connect models in series (see also overloaded *).
%   feedback       - Connect models with a feedback loop.
%   lft            - Generalized feedback interconnection.
%   connect        - Arbitrary block-diagram interconnection.
%   sumblk         - Specify summing junction (for use with CONNECT).
%   strseq         - Builds sequence of indexed strings (for I/O naming).
%
% System gain and dynamics.
%   dcgain         - Steady-state (D.C.) gain.
%   bandwidth      - System bandwidth.
%   DynamicSystem/norm  - H2 and Hinfinity norms of LTI models.
%   pole           - System poles.
%   zero           - System (transmission) zeros.
%   order          - Model order (number of states).
%   pzmap          - Pole-zero map.
%   iopzmap        - Input/output pole-zero map.
%   damp           - Natural frequency and damping of system poles.
%   esort          - Sort continuous poles by real part.
%   dsort          - Sort discrete poles by magnitude.
%   stabsep        - Stable/unstable decomposition.
%   modsep         - Region-based modal decomposition.
%
% Time-domain analysis.
%   step           - Step response.
%   stepinfo       - Step response characteristics (rise time, ...)
%   impulse        - Impulse response.
%   initial        - Free response with initial conditions.
%   lsim           - Response to user-defined input signal.
%   lsiminfo       - Linear response characteristics.
%   gensig         - Generate input signal for LSIM.
%   covar          - Covariance of response to white noise.
%
% Frequency-domain analysis.
%   bode           - Bode diagrams of the frequency response.
%   bodemag        - Bode magnitude diagram only.
%   sigma          - Singular value frequency plot.
%   nyquist        - Nyquist plot.
%   nichols        - Nichols plot.
%   margin         - Gain and phase margins.
%   allmargin      - All crossover frequencies and related gain/phase margins.
%   freqresp       - Frequency response over a frequency grid.
%   evalfr         - Evaluate frequency response at given frequency.
%
% Model simplification.
%   minreal        - Minimal realization and pole/zero cancellation.
%   sminreal       - Structurally minimal realization (state space).
%   hsvd           - Hankel singular values (state contributions)
%   balred         - Reduced-order approximations of linear models.
%   modred         - Model order reduction.
%
% Compensator design.
%   rlocus         - Evans root locus.
%   place          - Pole placement.
%   estim          - Form estimator given estimator gain.
%   reg            - Form regulator given state-feedback and estimator gains.
%   pidtune        - Tune PID controller based on linear plant model.
%
% LQR/LQG design.
%   ss/lqg         - Single-step LQG design.
%   lqr, dlqr      - Linear-Quadratic (LQ) state-feedback regulator.
%   lqry           - LQ regulator with output weighting.
%   lqrd           - Discrete LQ regulator for continuous plant.
%   lqi            - Linear-Quadratic-Integral (LQI) controller.
%   kalman         - Kalman state estimator.
%   kalmd          - Discrete Kalman estimator for continuous plant.
%   lqgreg         - Build LQG regulator from LQ gain and Kalman estimator.
%   lqgtrack       - Build LQG servo-controller.
%   augstate       - Augment output by appending states.
%
% State-space (SS) models.
%   rss            - Random stable continuous-time state-space models.
%   drss           - Random stable discrete-time state-space models.
%   ss2ss          - State coordinate transformation.
%   canon          - Canonical forms of state-space models.
%   ctrb           - Controllability matrix.
%   obsv           - Observability matrix.
%   gram           - Controllability and observability gramians.
%   prescale       - Optimal scaling of state-space models.  
%   balreal        - Gramian-based input/output balancing.
%   xperm          - Reorder states.   
%
% Frequency response data (FRD) models.
%   chgunits       - Change frequency vector units.
%   fcat           - Merge frequency responses.
%   fselect        - Select frequency range or subgrid.
%   fnorm          - Peak gain as a function of frequency.
%   frd/abs        - Entrywise magnitude of the frequency response.
%   frd/real       - Real part of the frequency response.
%   frd/imag       - Imaginary part of the frequency response.
%   frd/interp     - Interpolate frequency response data.
%   mag2db         - Convert magnitude to decibels (dB).
%   db2mag         - Convert decibels (dB) to magnitude.
%
% Time delays.
%   hasdelay       - True for models with time delays.
%   totaldelay     - Total delay between each input/output pair.
%   delay2z        - Replace delays by poles at z=0 or FRD phase shift.
%   pade           - Pade approximation of continuous-time delays.
%   thiran         - Thiran approximation of fractional discrete-time delays.
%
% Model characteristics and model arrays.
%   isct           - True for continuous-time models.
%   isdt           - True for discrete-time models.
%   isproper       - True for proper models.
%   issiso         - True for single-input/single-output models.
%   isstable       - True for models with stable dynamics.
%   InputOutputModel/size    - Size of model or model array.
%   InputOutputModel/ndims   - Number of dimensions.
%   InputOutputModel/nmodels - Number of models in model array.
%   InputOutputModel/isempty - True for empty models.
%   InputOutputModel/reshape - Reshape model array.
%   InputOutputModel/permute - Permute model array dimensions.
%
% Overloaded arithmetic operations.
%   +, -           - Add and subtract systems (parallel connection).
%   *              - Multiply systems (series connection).
%   \              - Left divide -- sys1\sys2 means inv(sys1)*sys2.
%   /              - Right divide -- sys1/sys2 means sys1*inv(sys2).
%   ^              - Powers of a given system.
%   '              - Pertransposition.
%   .'             - Transposition of input/output map.
%   .*             - Element-by-element multiplication.
%   [..]           - Concatenate models along inputs or outputs.
%   stack          - Stack models/arrays along some array dimension.
%   InputOutputModel/inv  - Inverse of input/output model.
%   InputOutputModel/conj - Complex conjugation of model coefficients.
%
% Matrix equation solvers and linear algebra.
%   lyap, dlyap         - Solve Lyapunov equations.
%   lyapchol, dlyapchol - Square-root Lyapunov solvers.
%   care, dare          - Solve algebraic Riccati equations.
%   gcare, gdare        - Generalized Riccati solvers.
%   bdschur             - Block diagonalization of a square matrix.
%
% Visualization and plot manipulation.
%   Type "help ctrlguis" for details on how to customize plots. 
%
% Demonstrations.
%   Type "demo" or "help ctrldemos" for a list of available demos.


%   Copyright 1986-2010 The MathWorks, Inc.






