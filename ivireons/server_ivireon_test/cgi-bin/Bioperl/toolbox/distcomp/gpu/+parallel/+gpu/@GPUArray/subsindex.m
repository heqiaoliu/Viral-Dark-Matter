function idx = subsindex( idx ) %#ok<INUSD>
%SUBSINDEX Subscript index for GPUArray
%   Not supported


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:28:24 $

error( 'parallel:gpu:NoIndexing', 'Indexing is not supported for GPUArrays.' );
