function A = sparse(varargin)
%SPARSE Create sparse codistributed matrix
%   SD = SPARSE(FD) converts a full codistributed array FD to a sparse
%   codistributed array SD.
%   
%   The following syntaxes are not supported for codistributed arrays:
%   S = SPARSE(ROWS,COLS,VALS,M,N,NZMAX)
%   S = SPARSE(ROWS,COLS,VALS,M,N)
%   S = SPARSE(ROWS,COLS,VALS)
%   
%   Conversion Example:
%   N = 1000;
%   D = codistributed.eye(N);
%   S = sparse(D)
%   
%   returns S = codistributed.speye(N).
%   
%   f = issparse(D)
%   t = issparse(S)
%   
%   returns f = false and t = true.
%   
%   See also SPARSE, CODISTRIBUTED, CODISTRIBUTED/EYE, CODISTRIBUTED/SPEYE.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/08/29 08:23:41 $

error(nargchk(1, 6, nargin, 'struct'));

if nargin ~= 1
    error('distcomp:codistributed:sparse:notOneInput',...
          ['Sparse with multiple input arguments is not supported on ' ...
           'codistributed arrays.  Only sparse(D) is supported.']);
end

% Implementation of S = sparse(coDd):
A  = varargin{1};
codistr = getCodistributor(A);
LP = getLocalPart(A);

numDims = length(codistr.Cached.GlobalSize);
if numDims > 2
    error('distcomp:codistributed:sparse:TooHighDimArray', ...
          ['Cannot convert %d dimensional arrays to sparse.  Only vectors ' ...
           'and matrices can be converted to sparse.'], numDims);
end

try
    [LP, codistr] = codistr.hSparsifyImpl(@sparse, LP);
catch e
    throw(e); % Strip off stack.
end

A = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK>

