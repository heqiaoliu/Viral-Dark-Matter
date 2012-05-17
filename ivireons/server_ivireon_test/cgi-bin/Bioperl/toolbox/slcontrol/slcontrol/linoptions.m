function opt = linoptions(varargin)
%LINOPTIONS Set options for finding operating points and linearizations
%
% OPT=LINOPTIONS creates a linearization options object with the default 
% settings. The variable, OPT, is passed to the functions FINDOP and 
% LINEARIZE to specify options for finding operating points and 
% linearization. 
%
% OPT=LINOPTIONS('Property1','Value1','Property2','Value2',...) creates a 
% linearization options object, OPT, in which the option given by 
% Property1 is set to the value given in Value1, the option given by 
% Property2 is set to the value given in Value2, etc. 
% 
% The following options can be set with linoptions:
%
%   LinearizationAlgorithm set to 'numericalpert' (default is 'blockbyblock') 
%   to enable numerical-perturbation linearization (as in MATLAB 5) where 
%   root level inports and states are numerically perturbed. Linearization 
%   annotations are ignored and root level inports and outports are used 
%   instead.
% 
%   'blockbyblock' and 'numericalpert' options:
%
%       SampleTime - The interval of time at which the signal is sampled. 
%       Nonzero for discrete systems, 0 for continuous systems, -1 (default) 
%       to use the longest sample time that contributes to the linearized model.
%
%       UseFullBlockNameLabels - Set to 'off' (default) to use truncated names 
%       for the linearization I/Os and states in the linearized model. Set to 
%       'on' to use the full block path name of the linearization I/Os and 
%       states..
%
%       UseBusSignalLabels - Set to 'off' (default) to use block/signal information
%       to label the linearization I/Os in the linearized model. Set to 
%       'on' to use bus signal names to label the linearization I/Os in the 
%       linearized model.
%
%   'blockbyblock' algorithm options:
%
%       BlockReduction - Set to 'on' (default) to eliminate blocks from the
%       linearized model that are not in the path of the linearization. Set
%       to 'off' to include these blocks in the linearized model.
%
%       IgnoreDiscreteStates - Set to 'on' to remove any discrete states
%       from the linearization. Set to 'off' (default) to include discrete 
%       states.
%
%       RateConversionMethod - Set to 'zoh' (default) to use the zero order
%       rate conversion routine when linearizing a multirate system.  Set
%       to 'tustin' to use the Tustin (bilinear) method.  Set to 'prewarp'
%       to use the Tustin approximation with prewarping. Set to
%       'upsampling_zoh', 'upsampling_tustin', 'upsampling_prewarp' to
%       upsample discrete states when possible and to use 'zoh', 'tustin',
%       and 'prewarp' respectively for all other rate conversions.  The
%       upsampling is only performed when converting discrete states at a
%       sample time Ts0 to a higher rate Ts = Ts0/L when L is an integer
%       factor.
%
%       PreWarpFreq - The critical frequency Wc (in rad/sec) used by the
%       'prewarp' option when linearizing a multirate system.
%
%       UseExactDelayModel - Set to 'on' to return a linear model with an 
%       exact delay representation.  Set to 'off' (default) to return a model 
%       with approximate delays.
%
%    'numericalpert' algorithm options:
%
%       NumericalPertRel - Set the perturbation level for obtaining the linear 
%       model (default 1e-5) according to:
%               NumericalXPert = NumericalPertRel+1e-3*NumericalPertRel*ABS(X)
%               NumericalUPert = NumericalPertRel+1e-3*NumericalPertRel*ABS(U)
%     
%       NumericalXPert - Individually set the perturbation levels for the
%       system's states.
%
%       NumericalUPert - Individually set the perturbation levels for the
%       system's inputs.
%
%   OptimizerType - Set optimizer type to be used by trim optimization if the 
%   Optimization Toolbox is installed. The available optimizer types are:
%
%       'graddescent_elim', the default optimizer, enforces an equality
%       constraint to force the time derivatives of states to be zero
%       (dx/dt=0, x(k+1)= x(k)) and the output signals to be equal to their
%       specified 'Known' value. The optimizer fixes the states, x, and
%       inputs, u, that are marked as 'Known' in an operating point
%       specification and then optimizes the remaining variables.
%
%       'graddescent', enforces an equality constraint to force the time
%       derivatives of states to be zero (dx/dt=0, x(k+1)= x(k)) and the
%       output signals to be equal to their specified 'Known' value. FINDOP
%       also minimizes the error between the states, x, and inputs, u, that
%       are marked as 'Known' in an operating point specification. If there
%       are not any inputs or states marked as 'Known', FINDOP attempts to
%       minimize the deviation between the initial guesses for x and u and
%       their trimmed values. 
%
%       'lsqnonlin' fixes the states, x, and inputs, u, that are marked as
%       'Known' in an operating point specification and optimizes the
%       remaining variables. The algorithm then tries to minimize the both
%       the error in the time derivatives of the states (dx/dt=0, x(k+1)=
%       x(k)) and the error between the outputs and their specified 'Known'
%       values.
% 
%       'simplex' uses the same cost function as 'lsqnonlin' with the
%       direct search optimization routine found in FMINSEARCH.
% 
%   See the Optimization Toolbox documentation for more information on these 
%   algorithms. If you do not have the Optimization Toolbox, you can access 
%   the documentation at www.mathworks.com/support/.
%
%   OptimizationOptions - Set options for use with the optimization
%   algorithms. These options are the same as those set with OPTIMSET. See
%   the Optimization Toolbox documentation for more information on these 
%   algorithms. 
%
%   DisplayReport - Set to 'on' to display the operating point summary
%   report when running FINDOP. Set to 'off' to suppress the display of
%   this report. Set to 'iter' to display an iterative update of the
%   optimization progress.
%
%   See also FINDOP, LINEARIZE

%  Author(s): John Glass
%  Revised:
% Copyright 2004-2008 The MathWorks, Inc.
% $Revision: 1.1.6.12 $ $Date: 2008/10/31 07:33:50 $

% Create the object
opt = LinearizationObjects.linoptions;

% Set the user defined properties
for ct = 1:(nargin/2) 
    opt.(varargin{2*ct-1}) = varargin{2*ct};
end
