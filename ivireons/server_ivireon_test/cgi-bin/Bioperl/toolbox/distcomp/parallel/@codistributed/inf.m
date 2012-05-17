function D = inf(varargin)
%CODISTRIBUTED.INF Infinity codistributed array
%   D = CODISTRIBUTED.INF(N) is an N-by-N codistributed matrix of INFs.
%   
%   D = CODISTRIBUTED.INF(M,N) is an M-by-N codistributed matrix of INFs.
%   
%   D = CODISTRIBUTED.INF(M,N,P,...) or CODISTRIBUTED.INF([M,N,P,...])
%   is an M-by-N-by-P-by-... codistributed array of INFs.
%   
%   D = CODISTRIBUTED.INF(M,N,P,..., CLASSNAME) or 
%   CODISTRIBUTED.INF([M,N,P,...], CLASSNAME) is an M-by-N-by-P-by-... 
%   codistributed array of INFs of class specified by CLASSNAME.  CLASSNAME 
%   must be either 'single' or 'double'.
%   
%   Other optional arguments to CODISTRIBUTED.INF must be specified after the
%   size and class arguments, and in the following order:
%   
%     CODISTR - A codistributor object specifying the distribution scheme of
%     the resulting array.  If omitted, the array is distributed using the
%     default distribution scheme.
%   
%     'noCommunication' - Specifies that no communication is to be performed
%     when constructing the array, skipping some error checking steps.
%   
%   As shown in the example, all forms of the built-in function have been 
%   overloaded for codistributed arrays.
%   
%   Example:
%   % Create a 1000-by-1 codistributed array of underlying class 'single' 
%   % containing the value Inf:
%   spmd
%       N = 1000;
%       D1 = codistributed.inf(N, 1,'single')
%       D2 = codistributed.Inf(1, N)
%   end
%   
%   See also INF, CODISTRIBUTED, CODISTRIBUTED/ZEROS, CODISTRIBUTED/ONES,
%   CODISTRIBUTED.BUILD, CODISTRIBUTOR.


%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/25 21:59:09 $

D = codistributed.pBuildFromFcn(@inf, varargin{:});
