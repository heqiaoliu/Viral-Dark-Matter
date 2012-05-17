function varargout = eig(varargin)
%EIG Eigenvalues and eigenvectors of codistributed array
%   D = EIG(A)
%   [V,D] = EIG(A)
%   
%   A must be real symmetric or complex Hermitian.
%   
%   The generalized problem EIG(A,B) is not available.
%   
%   Example:
%   spmd
%       N = 1000;
%       A = codistributed.rand(N);
%       A = A+A'
%       [V,D] = eig(A)
%       normest(A*V-V*D)
%   end
%   
%   computes a real symmetric A and its eigenvalues D and eigenvectors V
%   such that A*V is within round-off error of V*D.
%   
%   See also EIG, CODISTRIBUTED, CODISTRIBUTED/RAND.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/01/25 21:31:35 $

A = varargin{1};
if ~isaUnderlying(A,'float') || ndims(A) > 2 || issparse(A)
    error('distcomp:codistributed:eig:notReal', ...
          'EIG is only supported for codistributed full floating point arrays.');
end

if nargin > 1
    error('distcomp:codistributed:eig:noGeneralEig', ...
        ['Generalized eigenvalue problem is not yet available for' ...
        ' codistributed arrays.'])
end

if all(all(isfinite(A))) == false
   error('distcomp:codistributed:eig:matrixWithNaNInf',...
         'Input to EIG must not contain NaN or Inf.');
end

if isequal(A,A')
    [varargout{1:nargout}]=scalaEig(A);
else
    error('distcomp:codistributed:eig:noNonSymEig', ...
        ['Non symmetric eigenvalue problem is not yet available for' ...
        ' codistributed arrays.'])
end
