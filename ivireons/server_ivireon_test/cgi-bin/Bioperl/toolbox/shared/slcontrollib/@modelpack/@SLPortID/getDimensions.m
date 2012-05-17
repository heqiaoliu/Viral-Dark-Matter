function dims = getDimensions(this)
% GETDIMENSIONS Returns the dimensions of the port identified by THIS.
%
% DIMS equals
%   1 for a scalar signal,
%   n for a vector signal of size n,
%   [m,n] for a matrix-valued signal of size [m,n].
%
% NOTE: A vector signal of size n is not the same as matrix-valued signals of
% size [n,1] or [1,n].

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:24:40 $

dims = get(this, 'Dimensions');
