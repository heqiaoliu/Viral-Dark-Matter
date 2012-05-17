function x = isempty( obj ) %#ok<INUSD>
%ISEMPTY Composite method
%   ISEMPTY( C ) always returns false for a Composite

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2008/06/24 17:03:18 $

    % Composites are never empty.
    x = false;
end
    
