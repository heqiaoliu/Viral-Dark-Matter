function [settings, X] = daugment(startdes,nruns,model,varargin)
%DAUGMENT Augment D-Optimal design.
%   [SETTINGS, X] = DAUGMENT(STARTDES,NRUNS,MODEL) adds NRUNS runs
%   to an experimental design using the coordinate-exchange D-optimal
%   algorithm.  STARTDES is a matrix of factor settings in the original
%   design.  Outputs are the factor settings matrix SETTINGS, and the
%   associated matrix of model terms X (oftens called the design matrix).
%   MODEL controls the order of the regression model.  By default, DAUGMENT
%   returns the design matrix for a linear additive model with a constant
%   term.  MODEL can be any of the following strings:
%
%     'linear'        constant and linear terms (the default)
%     'interaction'   includes constant, linear, and cross product terms.
%     'quadratic'     interactions plus squared terms.
%     'purequadratic' includes constant, linear and squared terms.
%
%   Alternatively MODEL can be a matrix of term definitions as
%   accepted by the X2FX function.
%
%   The DAUGMENT function augments an existing design using the coordinate-
%   exchange algorithm; the 'start' option of the CANDEXCH function
%   provides the same functionality using the row-exchange algorithm.
%
%   [SETTINGS, X] = DAUGMENT(...,'PARAM1',VALUE1,'PARAM2',VALUE2,...)
%   provides more control over the design generation through a set of
%   parameter/value pairs.  Valid parameters are the following:
%
%      Parameter     Value
%      'display'     Either 'on' or 'off' to control display of
%                    iteration counter (default = 'on').
%      'init'        Initial design as a matrix with NRUNS rows
%                    (default is a randomly selected set of points).
%      'maxiter'     Maximum number of iterations (default = 10).
%      'tries'       Number of times to try to generate a design from a
%                    new starting point, using random points for each
%                    try except possibly the first (default 1). 
%      'bounds'      Lower and upper bounds for each factor, specified
%                    as a 2-by-NFACTORS matrix, where NFACTORS is the
%                    number of factors.  Alternatively, this value can
%                    be a cell array containing NFACTORS elements, each
%                    element specifying the vector of allowable values for
%                    the corresponding factor.
%      'levels'      Vector of number of levels for each factor.
%      'excludefun'  Function to exclude undesirable runs.
%      'categorical' Indices of categorical predictors.
%      'options'     A structure that contains options specifying whether to
%                    compute multiple tries in parallel, and specifying how
%                    to use random numbers when generating the starting points
%                    for the tries. This argument can be created by a call to 
%                    STATSET. DAUGMENT uses the following fields:
%                        'UseParallel'
%                        'UseSubstreams'
%                        'Streams'
%                    For information on these fields see PARALLELSTATS.
%                    NOTE: if 'UseParallel' is 'always' and 'UseSubstreams' 
%                    is 'never', then the length of Streams must equal the number
%                    of processors used by DAUGMENT. There are two possibilities. 
%                    If a MATLAB pool is open, then Streams is the same length as
%                    the size of the MATLAB pool. If a MATLAB pool is not open,
%                    then Streams must supply a single random number stream.
%
%   See also CORDEXCH, X2FX, CANDEXCH, STATSET, PARALLELSTATS.

%   Copyright 1993-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.1.2.1 $  $Date: 2010/07/06 14:43:04 $

nfactors = size(startdes,2);
if nargin<3, model='linear'; end
[settings,X] = cordexch(nfactors,nruns,model,'start',startdes,varargin{:});
