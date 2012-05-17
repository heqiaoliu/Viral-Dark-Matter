function [settings, X] = dcovary(nfactors,covs,model,varargin)
%DCOVARY D-Optimal design with fixed covariates.
%   [SETTINGS, X] = DCOVARY(NFACTORS,COVARIATES,MODEL) uses a coordinate
%   exchange algorithm to generate a D-optimal design for NFACTORS factors,
%   subject to the constraint that it also include the fixed covariate
%   values in the input matrix COVARIATES.  The number of runs in the design
%   is taken to be the number of rows in the COVARIATES matrix.  The output
%   matrix SETTINGS is the matrix of factor settings for the design,
%   including the fixed covariates.  X is the matrix of term values (often
%   called the design matrix).  MODEL controls the order of the regression
%   model.  MODEL can be any of the following strings:
%
%     'linear'        constant and linear terms (the default)
%     'interaction'   includes constant, linear, and cross product terms.
%     'quadratic'     interactions plus squared terms.
%     'purequadratic' includes constant, linear and squared terms.
%
%   Alternatively MODEL can be a matrix of term definitions as
%   accepted by the X2FX function.  The model is applied to the fixed
%   covariates as well as the regular factors.  If you want to treat
%   the fixed covariates specially, for example by including linear
%   terms for them but quadratic terms for the regular factors, you can
%   do this by creating the proper MODEL matrix.
%
%   [SETTINGS, X] = DCOVARY(...,'PARAM1',VALUE1,'PARAM2',VALUE2,...)
%   provides more control over the design generation through a set of
%   parameter/value pairs.  Valid parameters are the following:
%
%      Parameter     Value
%      'display'     Either 'on' or 'off' to control display of
%                    iteration counter (default = 'on').
%      'init'        Initial design as an NRUNS-by-NFACTORS matrix
%                    (default is a randomly selected set of points).
%      'maxiter'     Maximum number of iterations (default = 10).
%      'tries'       Number of times to try to generate a design from a
%                    new starting point, using random points for each
%                    try except possibly the first (default 1). 
%      'bounds'      Lower and upper bounds for each factor, specified
%                    as a 2-by-NFACTORS matrix.  Alternatively, this value
%                    can be a cell array containing NFACTORS elements, each
%                    element specifying the vector of allowable values for
%                    the corresponding factor.
%      'levels'      Vector of number of levels for each factor.
%      'excludefun'  Function to exclude undesirable runs.
%      'categorical' Indices of categorical predictors.
%      'options'     A structure that contains options specifying whether to
%                    compute multiple tries in parallel, and specifying how
%                    to use random numbers when generating the starting points
%                    for the tries. This argument can be created by a call to 
%                    STATSET. DCOVARY uses the following fields:
%                        'UseParallel'
%                        'UseSubstreams'
%                        'Streams'
%                    For information on these fields see PARALLELSTATS.
%                    NOTE: if 'UseParallel' is 'always' and 'UseSubstreams' 
%                    is 'never', then the length of Streams must equal the number
%                    of processors used by DCOVARY. There are two possibilities. 
%                    If a MATLAB pool is open, then Streams is the same length as
%                    the size of the MATLAB pool. If a MATLAB pool is not open,
%                    then Streams must supply a single random number stream.
%
%   The DCOVARY function creates a starting design that includes the
%   fixed covariate values, and then iterates by changing the non-fixed
%   coordinates of each design point in an attempt to reduce the variance
%   of the coefficients that would be estimated using this design.
%
%   Example:  Generate a design for three factors in 2 blocks of 4 runs.
%      blk = [-1 -1 -1 -1  1 1 1 1]';
%      dsgn = dcovary(3,blk);
%
%   See also CORDEXCH, DAUGMENT, ROWEXCH, X2FX, STATSET, PARALLELSTATS.

%   Copyright 1993-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.1.2.1 $  $Date: 2010/07/06 14:43:05 $

nruns = size(covs,1);
if nargin<3, model='linear'; end
[settings,X] = cordexch(nfactors,nruns,model,'covariates',covs,varargin{:});
