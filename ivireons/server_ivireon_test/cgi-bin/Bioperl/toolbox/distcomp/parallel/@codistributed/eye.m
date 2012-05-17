function D = eye(varargin)
%CODISTRIBUTED.EYE Identity codistributed matrix
%   D = CODISTRIBUTED.EYE(N) is the N-by-N codistributed matrix with ones on
%   the diagonal and zeros elsewhere.
%   
%   D = CODISTRIBUTED.EYE(M,N) or CODISTRIBUTED.EYE([M,N]) is the M-by-N 
%   codistributed matrix with ones on the diagonal and zeros elsewhere.
%   
%   D = CODISTRIBUTED.EYE() is the codistributed scalar 1.
%   
%   D = CODISTRIBUTED.EYE(M,N,CLASSNAME) or CODISTRIBUTED.EYE([M,N],CLASSNAME)
%   is the M-by-N codistributed identity matrix with underlying data of 
%   class CLASSNAME.
%   
%   Other optional arguments to CODISTRIBUTED.EYE must be specified after the
%   size and class arguments, and in the following order:
%   
%     CODISTR - A codistributor object specifying the distribution scheme of
%     the resulting array.  If omitted, the array is distributed using the
%     default distribution scheme.
%   
%     'noCommunication' - Specifies that no communication is to be performed
%     when constructing the array, skipping some error checking steps.
%   
%   Example:
%   spmd
%       N = 1000;
%       % Create a 1000-by-1000 codistributed array with underlying class 'int32'.
%       D1 = codistributed.eye(N,'int32');
%       % N-by-N codistributed array, distributed by the first 
%       % dimension (rows):
%       D2 = codistributed.eye(N, codistributor('1d', 1))
%       % Underlying class 'single, using 2D block-cyclic codistributor.
%       D3 = codistributed.eye(N, 'single', codistributor('2dbc'), 'noCommunication')
%   end
%   
%   See also EYE, CODISTRIBUTED, CODISTRIBUTED.BUILD, CODISTRIBUTOR.
%   


%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/05/14 16:51:05 $

% Longest possible call sequence is:
% codistributed.eye(m, n, 'single', codistr, 'noCommunication').
error(nargchk(0, 5, nargin, 'struct'));

try
    [sizeVec, className, codistr] = codistributed.pParseBuildArgs('eye', varargin); %#ok<DCUNK>
catch E
    throwAsCaller(E);
end

if length(sizeVec) > 2
    error('distcomp:codistributed:eye:TooHighDim', ...
          'EYE only creates matrices, and cannot create %d-D arrays.', ...
          length(sizeVec));
end

try
    [LP, codistr] = codistr.hEyeImpl(sizeVec(1), sizeVec(2), className);
catch E
    throwAsCaller(E);
end

% The argument parsing already ascertained that we are called collectively, so
% no further error checking is needed.
D = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK>

end % End of eye.
