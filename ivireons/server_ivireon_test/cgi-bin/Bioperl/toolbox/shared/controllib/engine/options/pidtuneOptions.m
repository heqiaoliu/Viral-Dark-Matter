function obj = pidtuneOptions(varargin)
% PIDTUNEOPTIONS  Define options for the PIDTUNE command.
%  
%    OPT = PIDTUNEOPTIONS returns the default option set for PIDTUNE.
%
%    OPT = PIDTUNEOPTIONS('Option1',Value1,'Option2',Value2,...) uses
%    name/value pairs to override the default values for 'Option1',
%    'Option2',...
% 
%    Supported tuning options include:
%  
%    CrossoverFrequency - Target frequency for the first 0dB crossover
%          of the open-loop transfer L = G*C. The default value is [],
%          which means that the algorithm automatically picks this
%          frequency based on the plant dynamics (the selected value is
%          returned by PIDTUNE in INFO). Typically, the crossover frequency
%          is roughly equal to the control bandwidth and its reciprocal is
%          roughly equal to the closed-loop response time. Increase the
%          CrossoverFrequency value to get a faster response and decrease
%          this value to improve stability.
%  
%    PhaseMargin - Target phase margin (default = 60 degrees). PIDTUNE
%          tries to enforce a phase margin greater or equal to this value.
%          Note that the selected crossover frequency may restrict the
%          achievable phase margin. Typically, higher phase margin improves
%          stability and overshoot but limits bandwidth and response speed.
%
%    NumUnstablePoles - Number of unstable poles in the plant G (default = 0). 
%          When G is an FRD model or a state-space model with internal
%          delays, you must specify the number of open-loop unstable poles
%          if any. Incorrect values may result in PID controllers that fail
%          to stabilize the real plant. This option is ignored for all
%          other model types.
%  
%   Example
%      G = tf(1,[1 3 3 1]);
%      % Design PID with 45 degrees of phase margin at 1.2 rad/sec
%      Options = pidtuneOptions('CrossoverFrequency',1.2,'PhaseMargin',45);
%      [C info] = pidtune(G,'pid',Options) 
%  
%   See also PIDTUNE.

%   Author(s): Rong Chen
%   Copyright 2009-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.4.2.1 $  $Date: 2010/06/24 19:43:27 $

try
    obj = initOptions(ltioptions.pidtune, varargin);
catch E
    throw(E);
end