function varargout = qr(varargin)
%QR Orthogonal-triangular decomposition for codistributed matrix
%   [Q,R] = QR(D)
%   [Q,R] = QR(D,0)
%   
%   D must be a full codistributed matrix of floating point numbers (single or double).
%   
%   The following syntaxes are not supported for full codistributed D:
%   [Q,R,E] = QR(D)
%   [Q,R,E] = QR(D,0)
%   X = QR(D)
%   X = QR(D,0)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.rand(N);
%       [Q,R] = qr(D)
%       norm(Q*R-D)
%   end
%   
%   See also QR, CODISTRIBUTED, CODISTRIBUTED/RAND.


%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.10.1 $  $Date: 2010/02/25 08:02:34 $

error(nargchk(1,2,nargin,'struct'));

A = varargin{1};
argList = distributedutil.CodistParser.gatherElements(varargin(2:end));
if ~isa(A, 'codistributed')
    [varargout{1:nargout}] = qr(A, argList{:});
    return;
end

if nargout ~= 2 || nargin == 2 && argList{1} ~= 0
   error('distcomp:codistributed:qr:supported',...
         'Only [Q, R] = qr(A) and [Q, R] = qr(A, 0) are currently supported.');
end


if ~isaUnderlying(A,'float') || ndims(A) > 2 || issparse(A)
    error('distcomp:codistributed:qr:notFloat', ...
          'QR is only supported for codistributed full floating point arrays.');
end

[varargout{1:nargout}]=scalaQR(A, argList{:});
