function D = false(varargin)
%CODISTRIBUTED.FALSE False codistributed array
%   D = CODISTRIBUTED.FALSE(N) is an N-by-N codistributed matrix 
%   of logical zeros, distributed using the default distribution scheme.
%   
%   D = CODISTRIBUTED.FALSE(M,N) is an M-by-N codistributed matrix
%   of logical zeros.
%   
%   D = CODISTRIBUTED.FALSE(M,N,P, ...) or CODISTRIBUTED.FALSE([M,N,P, ...])
%   is an M-by-N-by-P-by-... codistributed array of logical zeros.
%   
%   Optional arguments to CODISTRIBUTED.FALSE must be specified after the
%   size arguments, and in the following order:
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
%       N  = 1000;
%       D1 = codistributed.false(N) % 1000-by-1000 false codistributed array
%       D2 = codistributed.false(N, 2*N) % 1000-by-2000
%       D3 = codistributed.false([N, 2*N]) % 1000-by-2000
%       % N-by-N codistributed array, distributed by the first 
%       % dimension (rows):
%       D4 = codistributed.false(N, codistributor('1d', 1))
%       % Using 2D block-cyclic codistributor.
%       D5 = codistributed.false(N, codistributor('2dbc'), 'noCommunication')
%   end
%   
%   See also FALSE, CODISTRIBUTED, CODISTRIBUTED/TRUE, CODISTRIBUTED/ZEROS,
%   CODISTRIBUTED.BUILD, CODISTRIBUTOR.


%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/25 21:58:53 $

D = codistributed.pBuildFromFcn(@false, varargin{:});
