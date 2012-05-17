function D = randn(varargin)
%CODISTRIBUTED.RANDN codistributed array of normally distributed pseudorandom numbers
%   D = CODISTRIBUTED.RANDN(N) is an N-by-N codistributed matrix of normally
%   distributed pseudorandom numbers.
%   
%   D = CODISTRIBUTED.RANDN(M,N) is an M-by-N codistributed matrix
%   of normally distributed pseudorandom numbers.
%   
%   D = CODISTRIBUTED.RANDN(M,N,P, ...) or CODISTRIBUTED.RANDN([M,N,P, ...])
%   is an M-by-N-by-P-by-... codistributed array of normally distributed
%   pseudorandom numbers.
%   
%   D = CODISTRIBUTED.RANDN(M,N,P,..., CLASSNAME) or 
%   CODISTRIBUTED.RANDN([M,N,P,...], CLASSNAME) is an M-by-N-by-P-by-... 
%   codistributed array of normally distributed pseudorandom numbers of class 
%   specified by CLASSNAME.
%   
%   Other optional arguments to CODISTRIBUTED.RANDN must be specified after the
%   size and class arguments, and in the following order:
%   
%     CODISTR - A codistributor object specifying the distribution scheme of
%     the resulting array.  If omitted, the array is distributed using the
%     default distribution scheme.
%   
%     'noCommunication' - Specifies that no communication is to be performed
%     when constructing the array, skipping some error checking
%     steps.
%   
%   Examples:
%   spmd
%       N  = 1000;
%       D1 = codistributed.randn(N) % 1000-by-1000 codistributed array of randn
%       D2 = codistributed.randn(N, N*2) % 1000-by-2000
%       D3 = codistributed.randn([N, N*2], 'single') % underlying class 'single'
%       % N-by-N codistributed array, distributed by the first 
%       % dimension (rows):
%       D4 = codistributed.randn(N, codistributor('1d', 1))
%       % Using 2D block-cyclic codistributor.
%       D5 = codistributed.randn(N, codistributor('2dbc'), 'noCommunication')
%   end
%   
%   See also RANDN, CODISTRIBUTED, CODISTRIBUTED/ZEROS, CODISTRIBUTED/ONES,
%   CODISTRIBUTED.BUILD, CODISTRIBUTOR.


%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/25 22:00:11 $

D = codistributed.pBuildFromFcn(@randn, varargin{:});
