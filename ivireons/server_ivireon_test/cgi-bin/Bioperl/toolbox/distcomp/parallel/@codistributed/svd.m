function varargout = svd(varargin)
%SVD Singular value decomposition of codistributed matrix
%   If A is square, S = SVD(A) returns the singular values of A, and 
%   [U,S,V] = SVD(A) returns the singular value decomposition of A.
%   
%   If A is rectangular, you must specify "economy size" decomposition.
%   [U,S,V] = SVD(A,'econ')
%   
%   [U,S,V] = SVD(A, 0) is not supported.
%       
%   Example:
%   % Compute a real square matrix A, its singular values S, and singular
%   % vectors U and V such that A*V is within round-off error of U*S.
%   spmd
%       N = 1000;
%       A = codistributed.rand(N);
%       [U,S,V] = svd(A)
%       norm(A*V-U*S)
%   end
%   
%   
%   See also SVD, CODISTRIBUTED, CODISTRIBUTED/RAND.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/05/03 16:08:51 $

error(nargchk(1,2,nargin,'struct'));
error(nargoutchk(0,3,nargout,'struct'));

A = varargin{1};
argList = distributedutil.CodistParser.gatherElements(varargin(2:end));
if ~isa(A, 'codistributed')
    [varargout{1:nargout}] = svd(A, argList{:});
    return;
end

if ~isaUnderlying(A, 'float') || ( ndims(A) > 2 ) || issparse(A)
    error('distcomp:codistributed:svd:notFloat', ...
          ['SVD is only supported for codistributed full floating',...
           'point matrices (single or double).']);
end

switch nargin
  case 1
    if (nargout > 1 ) && ( size(A,1) ~= size(A,2) )
        error('distcomp:codistributed:svd:onlyEconomySvd', ...
              'Use svd(A,''econ'') for codistributed rectangular matrix.');
    end
  case 2
    isValidOptArg = @(x)( ischar(x) && strcmpi(x, 'econ') );
    if ~isValidOptArg( argList{1} )
        error('distcomp:codistributed:svd:unknownOptionForEconSizeDecomp', ...
              'Use svd(X,''econ'') for economy size decomposition.');
    end
end

[varargout{1:nargout}]=scalaSvd(A);
