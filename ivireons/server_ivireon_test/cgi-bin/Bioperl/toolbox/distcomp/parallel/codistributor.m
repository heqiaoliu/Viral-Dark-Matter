function A = codistributor(varargin)
%CODISTRIBUTOR   Create a distribution object for codistributed arrays
%   There are two schemes for distributing arrays.  The scheme denoted
%   by the string '1d' distributes an array along a single specified 
%   subscript, the distribution dimension, in a noncyclic, partitioned 
%   manner.  The scheme denoted by '2dbc' is employed by the parallel matrix
%   computation software ScaLAPACK, applies only to two-dimensional arrays,
%   and varies both subscripts over a rectangular computational grid of labs
%   in a blocked, cyclic manner.
%
%   DIST = CODISTRIBUTOR(), with no arguments, returns a default distribution
%   object with zero-valued or empty parameters, which can then trigger
%   references to other codistributed array functions.  For example,
%      D = ZEROS(...,CODISTRIBUTOR())
%      D = RANDN(...,CODISTRIBUTOR())
%
%   DIST = CODISTRIBUTOR('1d') is the same as DIST = CODISTRIBUTOR() and forms a
%   1D codistributor.
%
%   All of the following are valid, and the arguments DIM, PART, and GSIZE have
%   the same meaning as for the codistributor1d constructor:
%   DIST = CODISTRIBUTOR('1d',DIM) 
%   DIST = CODISTRIBUTOR('1d',DIM, PART) 
%   DIST = CODISTRIBUTOR('1d',DIM, PART, GSIZE) 
%
%   DIST = CODISTRIBUTOR('2dbc') forms a 2D block-cyclic codistributor.
%
%   All of the following are valid, and the arguments LBGRID, BLKSIZE, ORIENT,
%   and GSIZE have the same meaning as for the codistributor2dbc constructor:
%   DIST = CODISTRIBUTOR('2dbc',LBGRID) 
%   DIST = CODISTRIBUTOR('2dbc',LBGRID, BLKSIZE) 
%   DIST = CODISTRIBUTOR('2dbc',LBGRID, BLKSIZE, ORIENT) 
%   DIST = CODISTRIBUTOR('2dbc',LBGRID, BLKSIZE, ORIENT, GSIZE) 
%
%   Example: Create a codistributed array of size N-by-N-by-100, distributed
%   over the third dimension.
%     spmd
%         N = 1000;
%         A = codistributed.ones([N, N, 100], codistributor('1d', 3));
%     end
%
%   See also: codistributor1d, codistributor2dbc, 
%   codistributor1d/codistributor1d, codistributor2dbc/codistributor2dbc

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2009/10/12 17:28:09 $

error(nargchk(0, 5, nargin, 'struct'));

if isdeployed    
    error('distcomp:codistributor:noCodistributorWhenDeployed', ...
        ['In a deployed application codistributors can only ',...
         'be used in a parallel job or inside an spmd block with ' ...
         'an open matlabpool.']);
end
mpiInit;

% Possible calls:
%   A = CODISTRIBUTOR()
%   A = CODISTRIBUTOR('1d')
%   A = CODISTRIBUTOR('2dbc')
%   A = CODISTRIBUTOR('1d', <args to 1d constructor>)
%   A = CODISTRIBUTOR('2dbc', <args to 2dbc constructor>)

if 0 == nargin
    % quick return
    A = codistributor1d();
    return
end

% nargin >= 1
scheme = varargin{1};

if ~ischar(scheme)
    error('distcomp:codistributor:invalidSchemeType', ...
          'Distribution scheme argument must be a character string.' );
end

switch scheme
  case '1d'
      % varargin maps straight onto varargin for codistributor1d
      A = codistributor1d(varargin{2:end});
  case '2dbc'
      % varargin maps straight onto varargin for codistributor2dbc
      A = codistributor2dbc(varargin{2:end});
  otherwise
      error('distcomp:codistributor:invalidSchemeInput', ...
            'Invalid distribution scheme argument specified.');
end
