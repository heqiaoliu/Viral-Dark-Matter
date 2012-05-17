function [nll,VarParam] = mvregresslike(X,Y,Param,Covar,EstMethod,VarType,VarFormat)
%MVREGRESSLIKE Negative log-likelihood for multivariate regression.
%   NLOGL=MVREGRESSLIKE(X,Y,BETA,SIGMA,ALG) computes the negative log-
%   likelihood function NLOGL for a multivariate regression of the multivariate
%   observations in the N-by-D matrix Y on the predictor variables in X,
%   evaluated for the P-by-1 column vector BETA of coefficient estimates
%   and the D-by-D matrix SIGMA specifying the covariance of a row of Y.
%   ALG specifies the algorithm used in fitting the regression (see below).
%   NaN values in X or Y are taken to be missing.  Observations with
%   missing values in X are ignored.  Treatment of missing values in Y
%   depends on the algorithm.
%
%   Y is an N-by-D matrix of D-dimensional multivariate observations.  X
%   may be either a matrix or a cell array.  If D=1, X may be an N-by-P
%   design matrix of predictor variables.  For any value of D, X may also
%   be a cell array of length N, each cell containing a D-by-P design
%   matrix for one multivariate observation.  If all observations have the
%   same D-by-P design matrix, X may be a single cell.
%
%   ALG should match the algorithm used by MVREGRESS to obtain the
%   coefficient estimates BETA, and must be one of the following values:
%         'ecm'    ECM algorithm
%         'cwls'   Least squares conditionally weighted by SIGMA
%         'mvn'    Multivariate normal estimates computed after omitting
%                  rows with any missing values in Y.
%
%   [NLOGL,VARPARAM]=MVREGRESSLIKE(...) also returns an estimated covariance
%   matrix of the parameter estimates BETA.
%
%   [NLOGL,VARPARAM]=MVREGRESSLIKE(...,VARTYPE,VARFORMAT) specifies the type
%   and format of VARPARAM.  VARTYPE is either 'hessian' (default) to use
%   the Hessian or observed information, or 'fisher' to use the Fisher or
%   expected information.  VARFORMAT is either 'beta' (default) to compute
%   VARPARAM for BETA only, or 'full' to compute VARPARAM for both BETA and
%   SIGMA. The 'hessian' method takes into account the increased
%   uncertainties due to missing data.  The 'fisher' method uses the
%   complete-data expected information, and does not include uncertainty
%   due to missing data.
%
%   See also MVREGRESS, REGSTATS, MANOVA1.

%    Copyright 2006-2007 The MathWorks, Inc.
%    $Revision: 1.1.8.1 $ $Date: 2010/03/16 00:15:44 $
  
error(nargchk(4,7,nargin,'struct'));

if isempty(X) || (iscell(X) && isempty(X{1}))
    error('stats:mvregresslike:EmptyDesignArray', ...
        'Empty required input argument X.');
end
if isempty(Y)
    error('stats:mvregresslike:EmptyDataArray', ...
        'Empty required input argument Y.');
end
if isempty(Param)
    error('stats:mvregresslike:EmptyParam', ...
        'Empty required input argument BETA.');
end
if isempty(Covar)
    error('stats:mvregresslike:EmptyCovar', ...
        'Empty required input argument SIGMA.');
end

ny = size(Y,2);
if ~isequal(size(Covar),[ny ny])
    error('stats:mvregresslike:InconsistentDims',...
          'Covariance matrix must be %d-by-%d.',ny,ny);
elseif any(any(isnan(Covar)))
    error('stats:mvregresslike:NanCovar','Covariance matrix contains NaN.');
end
if ~isvector(Param)
    error('stats:mvregresslike:BadBeta','BETA must be a vector.');
end
Param = Param(:);

if nargin<5
    EstMethod = '';  % use data-dependent default
end
if ~isempty(EstMethod)
    if ~ischar(EstMethod) || size(EstMethod,1)~=1
        EstMethod = [];
    else
        EstMethod = strmatch(lower(EstMethod),{'cwls' 'ecm' 'mvn'});
    end
    if isempty(EstMethod)
        error('stats:mvregresslike:BadAlgorithm',...
              'ALG must be ''cwls'', ''ecm'', or ''mvn''.');
    end
end
if ~(isempty(EstMethod) || ismember(EstMethod,1:3))
    error('stats:mvregresslike:BadAlgorithm',...
          'ALG must be ''cwls'', ''ecm'', or ''mvn''.');
end

if nargin < 6 || isempty(VarType)
    VarType = 'hessian';
else
    % Check variance type
    okvals = {'hessian' 'fisher'};
    if ~ischar(VarType) || size(VarType,1)~=1
        VarType = [];
    else
        VarType = strmatch(lower(VarType),okvals);
    end
    if isempty(VarType)
        error('stats:mvregress:BadVarType',...
            'VARTYPE must be ''hessian'' or ''fisher''.');
    end
    VarType = okvals{VarType};
end

if nargin < 7 || isempty(VarFormat)
    VarFormat = 'paramonly';  % internal code for 'beta'
else
    % Check variance format
    okvals = {'beta' 'full'};
    if ~ischar(VarFormat) || size(VarFormat,1)~=1
        VarFormat = [];
    else
        VarFormat = strmatch(lower(VarFormat),okvals);
    end
    if isempty(VarFormat)
        error('stats:mvregress:BadVarFormat',...
            'VARFORMAT must be ''beta'' or ''full''.');
    end
    okvals{1} = 'paramonly';
    VarFormat = okvals{VarFormat};
end

% Check inputs, ignoring NaN rows for mvn method (3)
if isempty(EstMethod) && ~any(isnan(Y(:)))
    EstMethod = 3;   % use faster method for cases where others are equivalent
end
[NumSamples, NumSeries, NumParams, Y, X] = ...
          statcheckmvnr(Y, X, Param, Covar, isequal(EstMethod,3));

d = diag(Covar);
isdiagonal = isequal(Covar,diag(d));

if isdiagonal        % use faster formula for diagonal covariance
    CholState = sum(d<=0);
    CholCovar = diag(sqrt(d));
else
    [CholCovar, CholState] = chol(Covar);
end
if CholState > 0
    error('stats:mvregresslike:NonPosDefCov', ...
          'Covariance matrix is not positive-definite.');
end


if EstMethod==3                   % mvn method
    nll = -statmvnrobj(Y,X,Param,Covar,[],CholCovar,isdiagonal);
else                              % cwls or ecm method
    nll = -statecmobj(X,Y,Param,Covar,[],CholCovar,isdiagonal);
end

if nargout>=2
    Info = statecmmvnrfish(Y,X,Covar,VarType,VarFormat,CholCovar,isdiagonal);
    VarParam = inv(Info);
end
