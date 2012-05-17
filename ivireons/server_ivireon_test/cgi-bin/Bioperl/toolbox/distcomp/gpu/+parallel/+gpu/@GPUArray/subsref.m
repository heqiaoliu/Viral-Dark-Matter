function varargout = subsref( obj, idx ) %#ok<INUSD,STOUT>
%SUBSREF Subscripted reference for GPUArray
%   Not supported


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:57 $

error( 'parallel:gpu:NoIndexing', 'Indexing is not supported for GPUArrays.' );
