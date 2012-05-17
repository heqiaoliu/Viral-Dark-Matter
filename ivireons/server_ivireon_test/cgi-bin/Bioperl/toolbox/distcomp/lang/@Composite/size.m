function varargout = size( obj, varargin )
%SIZE Size of a Composite
%   SZ = SIZE( C ) returns a vector where the first element is 1, and the
%   second element is the length of the Composite.
%
%   [M, N] = SIZE( C ) returns the value 1 for M, and the length of the
%   Composite for N.

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2008/06/24 17:03:22 $
    
    % Build at least 1 output argument
    varargout = cell( 1, max( 1, nargout ) );

    % Defer to default size for the key vector
    [varargout{:}] = size( obj.KeyVector, varargin{:} );
end
