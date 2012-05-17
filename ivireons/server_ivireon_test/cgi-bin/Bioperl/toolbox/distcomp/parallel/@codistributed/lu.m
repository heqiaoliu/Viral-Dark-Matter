function varargout = lu(varargin)
%LU LU factorization for codistributed array
%   [L,U,P] = LU(D, 'vector')
%   
%   D must be a full codistributed matrix of floating point numbers (single or double).
%   
%   The following syntaxes are not supported for full codistributed D:
%   [...] = LU(D)
%   [...] = LU(D,'matrix')
%   X = LU(D,'vector')
%   [L,U] = LU(D,'vector')
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.rand(N);
%       [L,U,piv] = lu(D,'vector');
%       norm(L*U-D(piv,:), 1)
%   end
%   
%   See also LU, CODISTRIBUTED, CODISTRIBUTED/RAND.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/09/23 13:59:41 $

error(nargchk(1,2,nargin,'struct'));

A = varargin{1};
argList = distributedutil.CodistParser.gatherElements(varargin(2:end));
if ~isa(A, 'codistributed')
    [varargout{1:nargout}] = lu(A, argList{:});
    return;
end

if nargout ~= 3 || nargin < 2 || ~strcmpi(argList{1}, 'vector')
   error('discomp:codistributed:lu:supported',...
         'Only [L U P] = lu(A, ''vector'') is currently supported.');
end


if ~isaUnderlying(A,'float') || ndims(A) > 2 || issparse(A)
    error('distcomp:codistributed:lu:notFloat', ...
          'LU is only supported for codistributed full floating point arrays.');
end

[varargout{1:nargout}]=scalaLU(A);
