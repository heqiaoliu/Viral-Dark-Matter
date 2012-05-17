function varargout = chol(varargin)
%CHOL Cholesky factorization of codistributed matrix
%   R = CHOL(D)
%   [R,p] = CHOL(D)
%   L = CHOL(D, 'lower')
%   [L,p] = CHOL(D, 'lower')
%   
%   D must be a full codistributed matrix of floating point numbers (single or double).
%   
%   Example:
%   spmd
%       N = 1000;
%       D = 1 + codistributed.eye(N);
%       [R,p] = chol(D)
%   end
%   
%   See also CHOL, CODISTRIBUTED, CODISTRIBUTED/EYE.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/03/22 03:42:55 $

error(nargchk(1,2,nargin,'struct'));
error(nargchk(0,2,nargout,'struct'));

A = varargin{1};
argList = distributedutil.CodistParser.gatherElements(varargin(2:end));
if ~isa(A, 'codistributed')
    [varargout{1:nargout}] = chol(A, argList{:});
    return;
end

if ~isaUnderlying(A,'float') || ndims(A) > 2 || issparse(A)
    error('distcomp:codistributed:chol:notSupported', ...
          'CHOL is only supported for codistributed full floating point arrays.');
end
if size(A,1) ~= size(A,2)
    error('distcomp:codistributed:chol:square','Matrix must be square.');
end

if nargin == 1  % Upper factorization is default
    argList{1} = 'upper';
end
    
if ~any(strcmpi(argList{1},{'upper', 'lower'}))
    error('distcomp:codistributed:chol:inputType', ...
          'Shape flag must be ''upper'' or ''lower''');
end

[A, p]=scalaChol(A, argList{:});
   
if p > 0
    if nargout <= 1
        error('distcomp:codistributed:chol:posdef', ...
              'Matrix must be positive definite.');
    else
       indx.type = '()';
       indx.subs = {1:p-1, 1:p-1};
       A = subsref(A, indx);
    end
end
varargout{1} = A;
if nargout >= 2
    varargout{2} = p;
end

