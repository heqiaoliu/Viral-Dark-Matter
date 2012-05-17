classdef (Hidden) Minimize < handle
% Data log for minimization phase.
   
%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2010/04/11 20:36:10 $
   
   properties
      Gain = Inf   % Final peak gain value
      F = Inf      % Final objective value
      X            % Optimized parameters
      Iter = 0;    % Number of iterations
      FCount = 0;  % Number of function evaluations
      GCount = 0;  % Number of gradient evaluations
      SpecAbs      % Final spectral abscissa
      SpecAbsCons  % Effective spectral abscissa constraint
      SpecRad      % Final spectral radius
      SpecRadCons  % Effective spectral radius constraint
      GainHist     % Peak gain at each iteration
      SpecAbsHist  % Spectral abscissa at each iteration
      SpecRadHist  % Spectral radius at each iteration
      StepSizeHist % Line search step size at each iteration
      InitStepHist % Initial step size
      pHist        % ||p|| at each iteration
      dpHist       % ||dp|| at each iteration
      FCHist       % Number of function evaluations at each iteration
      Extra        % Freeform data
   end
end
