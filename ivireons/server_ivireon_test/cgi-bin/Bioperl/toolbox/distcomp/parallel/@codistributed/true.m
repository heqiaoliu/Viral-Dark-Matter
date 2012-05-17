function D = true(varargin)
%CODISTRIBUTED.TRUE True codistributed array
%   D = CODISTRIBUTED.TRUE(N) is an N-by-N codistributed matrix 
%   of logical ones.
%   
%   D = CODISTRIBUTED.TRUE(M,N) is an M-by-N codistributed matrix
%   of logical ones.
%   
%   D = CODISTRIBUTED.TRUE(M,N,P, ...) or CODISTRIBUTED.TRUE([M,N,P, ...])
%   is an M-by-N-by-P-by-... codistributed array of logical ones.
%   
%   Optional arguments to CODISTRIBUTED.TRUE must be specified after the
%   size arguments, and in the following order:
%   
%     CODISTR - A codistributor object specifying the distribution scheme of
%     the resulting array.  If omitted, the array is distributed using the
%     default distribution scheme.
%   
%     'noCommunication' - Specifies that no communication is to be performed
%     when constructing the array, skipping some error checking steps.
%   
%   Examples:
%   spmd
%       N  = 1000;
%       D1 = codistributed.true(N) % 1000-by-1000 true logical codistributed array
%       D2 = codistributed.true(N, N*2) % 1000-by-2000
%       D3 = codistributed.true([N, N*2]) % 1000-by-2000
%   end
%   
%   See also TRUE, CODISTRIBUTED, CODISTRIBUTED/FALSE, CODISTRIBUTED/ONES,
%   CODISTRIBUTED.BUILD, CODISTRIBUTOR.


%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/25 22:01:10 $

D = codistributed.pBuildFromFcn(@true, varargin{:});
