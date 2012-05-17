function c = dot(a,b,dim)
%DOT Vector dot product of codistributed array
%   C = DOT(A,B)
%   C = DOT(A,B,DIM)
%   
%   Example:
%   spmd
%       N = 1000;
%       d1 = codistributed.colon(1,N);
%       d2 = codistributed.ones(N,1);
%       d = dot(d1,d2)
%   end
%   
%   returns d = N*(N+1)/2.
%   
%   See also DOT, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/12/03 19:00:53 $

if nargin == 3
    dim = distributedutil.CodistParser.gatherIfCodistributed(dim);
    if ~isa(a, 'codistributed') && ~isa(b, 'codistributed')
        c = dot(a, b, dim);
        return;
    end
end

% Special case: A and B are vectors and dim not supplied
if isvector(a) && isvector(b) && nargin<3
    % Ensure that a and b are either both column vectors or both row vectors.
    isColVec = @(v) size(v, 1) > 1;
    if isColVec(a) ~= isColVec(b)
        b = b.';
    end
    % Return a replicated scalar rather than a codistributed scalar.  The
    % binary operation .* does a redistribution if necessary.
    c = gather(sum(conj(a).*b));
  return;
end

% Check dimensions
if any(size(a)~=size(b))
   error('distcomp:codistributed:dot:InputSizeMismatch', 'A and B must be same size.');
end

if nargin==2
  c = sum(conj(a).*b);
else
  c = sum(conj(a).*b,dim);
end
