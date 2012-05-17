function tol = getTolerance(Description,varargin)
% Centralized definition of default tolerances.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:28:49 $
switch Description
   case 'rank'
      % Tolerance for rank decisions
      tol = pow2(-39);  % eps^0.75;
   case 'infpole'
      % Thresholds for treating a pole as infinite
      % Used in elimAV and zpk_minreal_inf
      Ts = varargin{1};  % sampling time
      if Ts==0
         tol = [1e8,1e6];
      else
         tol = [1e6,1e4];
      end
   case 'infzero'
      % Thresholds for treating a zero as infinite
      % Note: Second value must be >1 for SSZERO to correctly
      %       assess relative degree
      Ts = varargin{1};  % sampling time
      if Ts==0
         tol = [1e12,1e4];
      else
         tol = [1e6,1e4];
      end
end
