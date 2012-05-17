% Simulink Control Design 
% Version 3.2 (R2010b) 03-Aug-2010  
%
% Linearization Analysis I/Os
%   getlinio   - Get linearization I/O settings for Simulink model 
%   linio      - Construct linearization I/O settings for Simulink model 
%   setlinio   - Assign I/O settings to Simulink model 
%
% Operating Points
%   addoutputspec - Add output specification to operating point specification 
%   opcond/copy   - Create copy of operating point or operating point 
%                   specification 
%   findop        - Find operating points from specifications or simulation 
%   initopspec    - Initialize operating point specification values 
%   opcond/get    - Get properties of linearization I/Os and operating points 
%   opcond/getinputstruct - Extract the input structure from an operating point
%   opcond/getstatestruct - Extract the state structure from an operating point
%   opcond/getxu  - Extract states and inputs from operating points 
%   operpoint     - Create operating point for Simulink model 
%   operspec      - Create operating point specifications for Simulink model 
%   opcond/set    - Set properties of linearization I/Os and operating points 
%   opcond/setxu  - Set states and inputs in operating points 
%   opcond/update - Update operating point object with structural changes 
%                   in model
%
% Linearization
%   linearize   - Obtain linear model from Simulink model 
%   linlft      - Obtain a linear model while removing specified Simulink blocks
%   linlftfold  - Fold specified block linearizations into a linearized model
%   getlinplant - Compute open loop plant model from Simulink diagram
%   linoptions  - Set options for finding operating points and linearization 
%
% Utility Functions
%   opcond/get - Get properties of linearization I/Os and operating points
%   opcond/set - Set properties of linearization I/Os and operating points 
%
% Frequency Response Estimation
%   frestimate           - Estimate frequency response of Simulink models
%   frestimateOptions    - Set options for frequency response estimation
%   frest.simView        - View simulation and estimation results
%   frest.simCompare     - Time-domain linearization validation
%   frest.findDepend     - Find path dependencies of a Simulink model
%   frest.findSources    - Find interfering time-varying source blocks
%
% Frequency Response Estimation Input Signals
%   frest.Sinestream              - Create sinestream input signal
%   frest.createFixedTsSinestream - Create sinestream input signal with fixed sample time
%   frest.Chirp                   - Create chirp input signal
%   frest.Random                  - Create random input signal
%   frest.createStep              - Create step input signal
%   generateTimeseries            - Generate MATLAB timeseries from input signals
%   plot                          - Plot input signals


% Copyright 2002-2010 The MathWorks, Inc.

