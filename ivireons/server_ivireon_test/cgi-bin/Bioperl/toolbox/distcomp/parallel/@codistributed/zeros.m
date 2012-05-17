function D = zeros(varargin)
%CODISTRIBUTED.ZEROS Zeros codistributed array
%   D = CODISTRIBUTED.ZEROS(N) is an N-by-N codistributed matrix of zeros.
%   
%   D = CODISTRIBUTED.ZEROS(M,N) is an M-by-N codistributed matrix of zeros.
%   
%   D = CODISTRIBUTED.ZEROS(M,N,P,...) or CODISTRIBUTED.ZEROS([M,N,P,...])
%   is an M-by-N-by-P-by-... codistributed array of zeros.
%   
%   D = CODISTRIBUTED.ZEROS(M,N,P,..., CLASSNAME) or 
%   CODISTRIBUTED.ZEROS([M,N,P,...], CLASSNAME) is an M-by-N-by-P-by-... 
%   codistributed array of zeros of class specified by CLASSNAME.
%   
%   Other optional arguments to CODISTRIBUTED.ZEROS must be specified after the
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
%       D1 = codistributed.zeros(N)   % 1000-by-1000 codistributed matrix of zeros
%       D2 = codistributed.zeros(N,N*2) % 1000-by-2000
%       D3 = codistributed.zeros([N,N*2], 'int8') % underlying class 'int8'
%       % N-by-N codistributed array, distributed by the first 
%       % dimension (rows):
%       D4 = codistributed.zeros(N, codistributor('1d', 1))
%       % Underlying class 'single, using 2D block-cyclic codistributor.
%       D5 = codistributed.zeros(N, 'single', codistributor('2dbc'), 'noCommunication')
%   end
%   
%   See also ZEROS, CODISTRIBUTED, CODISTRIBUTED/ONES, CODISTRIBUTED/BUILD,
%   CODISTRIBUTOR.


%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/25 22:01:23 $

D = codistributed.pBuildFromFcn(@zeros, varargin{:});
