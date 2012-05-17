function D = cell(varargin)
%CODISTRIBUTED.CELL Create codistributed cell array
%   D = CODISTRIBUTED.CELL(N) is a codistributed N-by-N cell array of
%   empty matrices.
%   
%   D = CODISTRIBUTED.CELL(M,N) or D = CODISTRIBUTED.CELL([M,N]) is a
%   codistributed M-by-N cell array of empty matrices.
%   
%   D = CODISTRIBUTED.CELL(M,N,P, ...) or CODISTRIBUTED.CELL([M,N,P, ...])
%   is an M-by-N-by-P-by-... codistributed cell array of empty matrices.
%   
%   Optional arguments to CODISTRIBUTED.CELL must be specified after the 
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
%       % Create a 1000-by-1000 codistributed cell array.
%       D1 = codistributed.cell(N) 
%       % N-by-N codistributed cell array, distributed by the first 
%       % dimension (rows).
%       D2 = codistributed.cell(N, codistributor('1d', 1)) 
%       % Using 2D block-cyclic codistributor.
%       D3 = codistributed.cell(N, codistributor('2dbc'), 'noCommunication')
%   end
%   
%   See also CELL, CODISTRIBUTED, CODISTRIBUTED/ZEROS, CODISTRIBUTED/ONES,
%   CODISTRIBUTED.BUILD, CODISTRIBUTOR.


%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/25 21:58:13 $

D = codistributed.pBuildFromFcn(@cell, varargin{:});
