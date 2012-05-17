function [fcn, data] = getUserDataToSPMD( Q ) %#ok<INUSD>
%getUserDataToSPMD - override this to supply user data to transfer
%

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2008/05/19 22:45:57 $

% Use a sub-function to ensure no data is associated with the function handle.
    fcn  = @iNoOp;
    data = [];
end

function x = iNoOp( x, y ) %#ok<INUSD>
end