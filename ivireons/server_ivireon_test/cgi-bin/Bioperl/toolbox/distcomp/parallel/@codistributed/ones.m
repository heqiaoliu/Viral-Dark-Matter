function D = ones(varargin)
%CODISTRIBUTED.ONES Ones codistributed array
%   D = CODISTRIBUTED.ONES(N) is an N-by-N codistributed matrix of ones.
%   
%   D = CODISTRIBUTED.ONES(M,N) is an M-by-N codistributed matrix of ones.
%   
%   D = CODISTRIBUTED.ONES(M,N,P,...) or CODISTRIBUTED.ONES([M,N,P,...])
%   is an M-by-N-by-P-by-... codistributed array of ones.
%   
%   D = CODISTRIBUTED.ONES(M,N,P,..., CLASSNAME) or 
%   CODISTRIBUTED.ONES([M,N,P,...], CLASSNAME) is an M-by-N-by-P-by-... 
%   codistributed array of ones of class specified by CLASSNAME.
%   
%   Other optional arguments to CODISTRIBUTED.ONES must be specified after the
%   size and class arguments, and in the following order:
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
%       D1 = codistributed.ones(N)   % 1000-by-1000 codistributed matrix of ones
%       D2 = codistributed.ones(N,N*2) % 1000-by-2000
%       D3 = codistributed.ones([N,N*2], 'int8') % underlying class 'int8'
%       % N-by-N codistributed array, distributed by the first 
%       % dimension (rows):
%       D4 = codistributed.ones(N, codistributor('1d', 1))
%       % Using 2D block-cyclic codistributor.
%       D5 = codistributed.ones(N, codistributor('2dbc'), 'noCommunication')
%   end
%   
%   See also ONES, CODISTRIBUTED, CODISTRIBUTED/ZEROS, CODISTRIBUTED/BUILD,
%   CODISTRIBUTOR.
%   


%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/25 21:59:48 $

D = codistributed.pBuildFromFcn(@ones, varargin{:});
