classdef (CaseInsensitiveProperties = true, TruncatedProperties = true) hinfstruct < ltioptions.Generic
   % Options set for structured H-infinity synthesis.
   
   % Author: P. Gahinet
   %   Copyright 2009-2010 The MathWorks, Inc.
   % $Revision: 1.1.8.4 $ $Date: 2010/05/10 17:37:00 $
   
   properties (Dependent)
      % Display level (default = 'off').
      %
      % This option controls the amount of information displayed by the
      % underlying optimization process. By default HINFSTRUCT runs silently
      % and no information is printed in the command window. Setting
      % Display='final' prints a one-line summary at the end of each
      % optimization run. Setting Display='iter' shows the optimization
      % progress after each iteration.
      Display
   end
      
   properties
      % Maximum number of iterations (default = 300).
      MaxIter = 300;
      
      % Number of randomized starts (default = 0).
      %
      % You can automatically run one or more optimizations starting from
      % random initial values to mitigate the risk of premature termination
      % due to local minima. Setting RandomStart=0 runs a single optimization
      % starting from the initial values of the tunable blocks. Setting
      % RandomStart=N>0 runs N additional optimizations starting from N
      % randomly generated values of the free parameters.
      RandomStart = 0;
      
      % Target H-infinity norm (default = 0).
      %
      % The optimization stops when the peak closed-loop gain falls below
      % the specified TargetGain value. Set TargetGain=0 to minimize the
      % peak closed-loop gain. Set TargetGain=Inf to only stabilize the
      % closed-loop system.
      TargetGain = 0;
      
      % Relative tolerance for termination criterion (default = 1e-3)
      %
      % The optimization stops when the relative decrease of the H-infinity
      % norm over the last 10 iterations falls below TolGain. Increasing 
      % TolGain speeds up termination at the expense of higher final values
      % for the H-infinity norm. Decreasing TolGain improves the final values
      % at the expense of more iterations.
      TolGain = 1e-3;
      
      % Maximum closed-loop natural frequency (default = Inf).
      %
      % Constrains the closed-loop poles to
      %    |p| < SpecRadius.
      % Use this option to prevent fast dynamics and high-gain control.
      % Setting SpecRadius=Inf automatically adjusts the spectral radius
      % (maximum natural frequency) based on the open-loop dynamics.
      SpecRadius = Inf;
      
      % Blocks to exclude from closed-loop stability test (default = {}).
      %
      % Some applications use fictitious blocks like weighting functions
      % or multipliers. While such blocks affect the closed-loop gain to
      % be minimized, they are of no concern when assessing closed-loop
      % stability of the actual control system. To ignore such blocks
      % and let them go unstable, list their names in the StableExclude
      % option. By default, all tunable blocks are included in the
      % closed-loop stability test.
      StableExclude = cell(0,1);
      
      % Stability boundary offset (default = 1e-7).
      %
      % Constrains the closed-loop poles to satisfy
      %    Re(p) < -StableOffset.
      % Increase this value to improve the stability of closed-loop poles
      % that are not visible in the closed-loop transfer function due to
      % pole/zero cancellations.
      StableOffset = 1e-7;
      
      
      
   end
   
   properties (Hidden)
      % Display and instrumentation options
      Trace = NSOptLog.Options();
      % Run Phase 2 when on
      Phase2 = 'off';
   end
   
   
   methods
      
      function value = get.Display(this)
         % GET method for Display property
         DV = {'off','final','iter'};
         value = DV{1+this.Trace.Verbosity};
      end
      
      function this = set.Display(this,value)
         % SET method for Display option
         DV = {'off','final','iter'};
         value = ltipack.matchKey(value,DV);
         if isempty(value)
            ctrlMsgUtils.error('Robust:design:hinfstruct10');
         else
            this.Trace.Verbosity = find(strcmp(value,DV))-1;
         end
      end
      
      function this = set.MaxIter(this,value)
         % SET method for MaxIter option
         if ~(isnumeric(value) && isscalar(value) && ...
               isreal(value) && ~isnan(value) && value>0)
            ctrlMsgUtils.error('Robust:design:hinfstruct11')
         end
         this.MaxIter = round(double(value));
      end
      
      function this = set.RandomStart(this,value)
         % SET method for RandomStart option
         if ~(isnumeric(value) && isscalar(value) && ...
               isreal(value) && isfinite(value) && value>=0)
            ctrlMsgUtils.error('Robust:design:hinfstruct12')
         end
         this.RandomStart = round(double(value));
      end
      
      function this = set.StableExclude(this,value)
         % SET method for StableExclude option
         if ischar(value)
            value = {value};
         elseif ~iscellstr(value)
            ctrlMsgUtils.error('Robust:design:hinfstruct13')
         end
         this.StableExclude = value(:);
      end
      
      function this = set.StableOffset(this,value)
         % SET method for StableOffset option
         if ~(isnumeric(value) && isscalar(value) && ...
               isreal(value) && isfinite(value) && value>=0)
            ctrlMsgUtils.error('Robust:design:hinfstruct14','StableOffset')
         end
         this.StableOffset = double(value);
      end
      
      function this = set.SpecRadius(this,value)
         % SET method for SpecRadius option
         if ~(isnumeric(value) && isscalar(value) && isreal(value) && value>0)
            ctrlMsgUtils.error('Robust:design:hinfstruct15')
         end
         this.SpecRadius = double(value);
      end
      
      function this = set.TargetGain(this,value)
         % SET method for TargetGain option
         if ~(isnumeric(value) && isscalar(value) && isreal(value) && value>=0)
            ctrlMsgUtils.error('Robust:design:hinfstruct14','TargetGain')
         end
         this.TargetGain = double(value);
      end
      
      function this = set.TolGain(this,value)
         % SET method for TolGain option
         if ~(isnumeric(value) && isscalar(value) && isreal(value) && value>0 && value<1)
            ctrlMsgUtils.error('Robust:design:hinfstruct16')
         end
         this.TolGain = double(value);
      end
      
   end
   
   methods (Access = protected)
      function cmd = getCommandName(~)
         cmd = 'hinfstruct';
      end
   end
   
end
