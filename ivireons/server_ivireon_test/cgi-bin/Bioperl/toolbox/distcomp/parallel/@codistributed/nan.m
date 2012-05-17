function D = nan(varargin)
%CODISTRIBUTED.NAN Build codistributed array containing Not-a-Number
%   D = CODISTRIBUTED.NAN(N) is an N-by-N codistributed matrix of NANs.
%   
%   D = CODISTRIBUTED.NAN(M,N) is an M-by-N codistributed matrix of NANs.
%   
%   D = CODISTRIBUTED.NAN(M,N,P,...) or CODISTRIBUTED.NAN([M,N,P,...])
%   is an M-by-N-by-P-by-... codistributed array of NANs.
%   
%   D = CODISTRIBUTED.NAN(M,N,P,..., CLASSNAME) or 
%   CODISTRIBUTED.NAN([M,N,P,...], CLASSNAME) is an M-by-N-by-P-by-... 
%   codistributed array of NANs of class specified by CLASSNAME.  CLASSNAME
%   must be either 'single' or 'double'.
%   
%   Other optional arguments to CODISTRIBUTED.NAN must be specified after the
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
%   spmd
%       N = 1000;
%       % Create a 1000-by-1 codistributed array of underlying class 'single'
%       % containing the value NaN.
%       D1 = codistributed.nan(N, 1,'single')
%       D2 = codistributed.NaN(1, N)
%       % N-by-N codistributed array, distributed by the first 
%       % dimension (rows):
%       D3 = codistributed.nan(N, codistributor('1d', 1))
%       % Using 2D block-cyclic codistributor.
%       D4 = codistributed.NaN(N, codistributor('2dbc'), 'noCommunication')
%   end
%   
%   See also NAN, CODISTRIBUTED, CODISTRIBUTED/ZEROS, CODISTRIBUTED/ONES,
%   CODISTRIBUTED.BUILD, CODISTRIBUTOR.


%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/25 21:59:36 $

D = codistributed.pBuildFromFcn(@nan, varargin{:});
