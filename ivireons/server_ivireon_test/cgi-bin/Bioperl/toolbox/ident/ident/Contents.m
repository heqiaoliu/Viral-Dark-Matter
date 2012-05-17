% System Identification Toolbox
% Version 7.4.1 (R2010b) 03-Aug-2010
%
% Help
%   idhelp           - A micromanual. Type "help idhelp" to get started.
%   idprops          - List of properties of toolbox objects.
%
% Demos
%   iddemo           - Demos of basic features and linear model estimation.
%
% Graphical User Interface
%   ident            - A comprehensive estimation and analysis GUI.
%   midprefs         - Specify a directory for start-up information.
%
% Simulation and prediction.
%   predict          - M-step ahead prediction.
%   pe               - Compute prediction errors.
%   sim              - Simulate a given system.
%   slident          - Simulink library for using the data and model objects.
%
% Data manipulation.
%   detrend          - Remove trends from data sets.
%   delayest         - Estimate the time delay (dead time) from data.
%   feedback         - Investigate feedback effects in data sets.
%   getTrend         - Get offset and linear trend information from data sets. 
%   iddata/fft       - Transform data from time to frequency domain.
%   iddata/ifft      - Transform data from frequency to time domain.
%   iddata/getexp    - Retrieve separate experiment(s) from multiple-experiment
%                      iddata objects.
%   iddata           - Construct a data object.
%   iddata/advice    - Advice about a data set.
%   iddata/merge     - Merge several experiments.
%   iddata/nkshift   - Shift data sequences.
%   iddata/plot      - Plot iddata objects.
%   iddata/resample  - Resample data by decimation and interpolation.
%   iddata/isnlarx   - Test if a nonlinear ARX model is better than linear.
%   misdata          - Estimate and replace missing input and output data.
%   idfilt           - Filter data through Butterworth filters.
%   idinput          - Generates input signals for identification.
%   isreal           - Check if a data set contains real data.
%   retrend          - Add trends to time domain data sets.
%
% Nonparametric estimation.
%   covf             - Covariance function estimate for a data matrix.
%   cra              - Correlation analysis.
%   etfe             - Empirical Transfer Function Estimate and Periodogram.
%   impulse          - Direct estimation of impulse response.
%   spa              - Spectral analysis.
%   spafdr           - Spectral analysis with frequency dependent resolution.
%   step             - Direct estimation of step response.
%
% Parametric model estimation.
%   ar               - AR-models of signals using various approaches.
%   armax            - Prediction error estimate of an ARMAX model.
%   arx              - LS-estimate of ARX-models.
%   bj               - Prediction error estimate of a Box-Jenkins model.
%   init             - Initialize (randomize) the parameters of a model.
%   ivar             - IV-estimates for the AR-part of a scalar time series.
%   iv4              - Approximately optimal IV-estimates for ARX-models.
%   n4sid            - State-space model estimation using a sub-space method.
%   nlarx            - Prediction error estimate of a nonlinear ARX model.
%   nlhw             - Prediction error estimate of a Hammerstein-Wiener model.
%   oe               - Prediction error estimate of an output-error model.
%   pem              - Prediction error estimate of a general model.
%
% Model structure creation.
%   idarx            - Create multivariable linear ARX models.
%   idfrd            - Create frequency response data models.
%   idgrey           - Create user-parameterized (grey-box) linear models.
%   idnlarx          - Create nonlinear ARX models.
%   idnlgrey         - Create nonlinear user-parameterized models.
%   idnlhw           - Create nonlinear Hammerstein-Wiener type models.
%   idpoly           - Create linear polynomial-type models.
%   idproc           - Create simple linear continuous time process models.
%   idss             - Create linear state space models.
%
% Model conversions.
%   idmodel/arxdata  - Extract ARX-matrices of idarx model.
%   c2d, d2c         - Continuous/discrete transformations. 
%   idnlarx/findop   - Find idnlarx model's operating point (input and state values).
%   idnlhw/findop    - Similar functionality as idnlarx/findop for idnlhw models.
%   data2state       - Map past input-output values to states of an idnlarx model.
%   linapp           - Linear approximation of nonlinear model for a given input.
%   linearize        - Small signal tangent linearization of nonlinear models.
%   idmodel/polydata - Extract polynomials associated with a given model.
%   idmodel/ssdata   - Extract state-space matrices.
%   idmodel/tfdata   - Extract numerators and denominators.
%   idmodel/zpkdata  - Extract zero/pole/gain and their standard deviations.
%   idfrd            - Model's frequency function, along with its covariance.
%   ss2ss            - State coordinate transformation.
%   idmodel/balred   - Reduced-order approximations of IDMODELs.
%                      (requires Control System Toolbox)                       
%   ss,tf,zpk,frd    - Transformations to LTI objects of Control System Toolbox.
%   Most Control System Toolbox conversion routines also apply to the 
%   model objects of System Identification Toolbox.
%
% Model presentation.
%   idmodel/advice   - Advice about an estimated model.
%   bode             - Bode diagram of a transfer function or spectrum 
%                      (with uncertainty regions).
%   impulse          - Impulse response of linear model (with uncertainty regions).
%   ffplot           - Frequency functions (with uncertainty regions).
%   nyquist          - Nyquist diagram of a linear model (with uncertainty regions).
%   plot             - Plot response of a model's characteristics.
%   present          - Display the model with uncertainties.
%   pzmap            - Zeros and poles of a linear model (with uncertainty regions).
%   step             - Step response of linear and nonlinear models.
%   view             - Show responses in the LTI viewer of Control System Toolbox.
%  
% Model validation.
%   compare          - Compare simulated/predicted output with measured output.
%   pe               - Prediction errors.
%   predict          - M-step ahead prediction.
%   resid            - Compute and test the residuals associated with a model.
%   sim              - Simulate a given system (with uncertainty).
%   idmodel/simsd	 - Illustrate model uncertainty by Monte Carlo simulations.
%   findstates       - Estimate initial states to achieve best fit to given data.
%
% Model structure selection.
%   aic              - Compute Akaike's information criterion.
%   fpe              - Compute final prediction criterion.
%   arxstruc         - Loss functions for families of ARX-models.
%   selstruc         - Select model structures according to various criteria.
%   idss/setstruc    - Set the structure matrices for idss objects.
%   struc            - Generate typical structure matrices for ARXSTRUC.
%
% Recursive parameter estimation.
%   rarx             - Compute estimates recursively for an ARX model.
%   rarmax           - Compute estimates recursively for an ARMAX model.
%   rbj              - Compute estimates recursively for a BOX-JENKINS model.
%   roe              - Compute estimates recursively for an output error model.
%   rpem             - Compute estimates recursively for a general model.
%   rplr             - Compute estimates recursively for a general model.
%   segment          - Segment data and track abruptly changing systems.
%
% Nonlinearity estimator objects. 
%   idnlfun/evaluate - Evaluate nonlinearity.
%   customnet        - Custom nonlinearity estimator.
%   deadzone         - Dead zone nonlinearity estimator.
%   idnlfun/initreset - Reset initialization of nonlinearity estimators.
%   linear           - Linear estimator.
%   neuralnet        - Neural network nonlinearity estimator 
%                      (requires Neural Network Toolbox).
%   poly1d           - One-dimensional polynomial estimator.
%   pwlinear         - Piecewise linear nonlinearity estimator.
%   saturation       - Saturation nonlinearity estimator. 
%   sigmoidnet       - Sigmoid network nonlinearity estimator.
%   treepartition    - Tree partition nonlinearity estimator.
%   unitgain         - Unit gain nonlinearity estimator.
%   wavenet          - Wavelet network nonlinearity estimator.
%
% Regressor and parameter management for nonlinear models.
%   idnlarx/addreg   - Add custom regressors to a nonlinear ARX model.
%   customreg        - Create custom regressors for a nonlinear ARX model.
%   idnlarx/getreg   - Get regressors of a nonlinear ARX model.
%   idnlgrey/getpar  - Get parameters of a nonlinear grey-box model.
%   idnlgrey/setpar  - Set parameters of a nonlinear grey-box model.
%   idnlgrey/getinit - Get initial states of a nonlinear grey-box model.
%   idnlgrey/setinit - Get initial states of a nonlinear grey-box model.
%   idnlarx/polyreg  - Create polynomial-type custom regressors.
%   idnlarx/getDelayInfo - Get maximum delay in each input-output channel.
%
% Bookkeeping and display facilities.
%   display          - Display of basic properties.
%   present          - More detailed display.
%   get, set         - Getting and setting the object properties.
%   getpvec          - Get parameter list of linear and nonlinear grey-box models.
%   setpname         - Set default parameter names in linear models.
%   timestamp        - Find out when the object was created.
%   fpe, aic         - Direct access to various model validation criteria.

%   Copyright 1986-2010 The MathWorks, Inc.
