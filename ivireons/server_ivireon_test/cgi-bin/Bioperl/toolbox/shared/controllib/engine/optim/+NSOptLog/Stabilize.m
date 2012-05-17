classdef (Hidden) Stabilize < handle
% Data log for stabilization phase.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2010/03/31 18:37:53 $
properties
      F            % Final objective value
      X            % Optimized parameters
      Iter = 0;    % Number of iterations
      FCount = 0;  % Number of function evaluations
      GCount = 0;  % Number of gradient evaluations
      SpecAbs      % Final spectral abscissa
      SpecAbsCons  % Effective spectral abscissa constraint
      SpecRad      % Final spectral radius
      SpecRadCons  % Effective spectral radius constraint
      SpecAbsHist  % Spectral abscissa at each iteration
      SpecRadHist  % Spectral radius at each iteration
      StepSizeHist % Line search step size at each iteration
      Extra        % Freeform data
   end
end
