function estimator = createEstimator(sys, data, varargin)
%CREATEESTIMATOR  Creates estimator for IDMODEL IDNLMODEL or IDNLFUN objects.
%
%   ESTIMATOR = CREATEESTIMATOR(SYS, DATA);
%
%   SYS holds the IDNLFUN, IDNLMODEL or IDMODEL object used for parameter
%   estimation. 
%
%   DATA is the IDDATA object used for parameter estimation.
%
%   ESTIMATOR = CREATEESTIMATOR(SYS, DATA, ALGO) allows custom
%   specification of estimation algorithm struct. If provided, algorithm is
%   properties are used from ALGO rather than from SYS.

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.10.5 $ $Date: 2008/10/02 18:51:13 $

% Initialize estimator.
estimator = [];

% Create appropriate estimator.
if isa(sys, 'idnlfun')
    SearchMethod = lower(varargin{1}.SearchMethod);
else
    SearchMethod = lower(sys.Algorithm.SearchMethod);
    %{
    if isfield(sys.Algorithm,'SearchMethod')
        SearchMethod = lower(sys.Algorithm.SearchMethod);
    elseif isfield(sys.Algorithm,'SearchDirection')
        SearchMethod = lower(sys.Algorithm.SearchDirection);
    end
    %}
end

switch SearchMethod
    case 'auto'
        if (isoptiminstalled && isa(sys, 'idnlgrey'))
            % When available, use lsqnonlin optimizer as default for
            % idnlgrey models.
            estimator = idestimatorpack.lsqnonlin;
        else
            % IDENT's built-in MLE optimizer.
             estimator = idestimatorpack.idminimizer;
             %estimator.initialize(sys, data, varargin{:});
        end
    case {'gn' 'gna' 'grad' 'lm'}
        % IDENT's built-in MLE optimizer.
        estimator = idestimatorpack.idminimizer;
    case 'lsqnonlin'
        estimator = idestimatorpack.lsqnonlin;
    case 'fmincon'
        disp('Not available yet.')
        %estimator = idestimatorpack.fmincon(sys, data, varargin{:});
    case 'fminsearch'
        disp('Not available yet.')
        %estimator = idestimatorpack.fminsearch(sys, data, varargin{:});
    case 'patternsearch'
        disp('Not available yet.')
        %estimator = estimatorpack.patternsearch(sys, data, varargin{:});
    otherwise
        ctrlMsgUtils.error('Ident:estimation:unavailableSearchMethod',SearchMethod)
end

estimator.initialize(sys, data, varargin{:});

