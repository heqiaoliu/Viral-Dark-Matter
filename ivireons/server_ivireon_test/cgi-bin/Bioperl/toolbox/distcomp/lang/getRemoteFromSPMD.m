function [fcnH, userData] = getRemoteFromSPMD( anyData ) %#ok<INUSD>
%getRemoteFromSPMD - allows customisation of return of Remote data from SPMD


% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2008/05/19 22:45:56 $

    fcnH = @spmdlang.plainCompositeBuilder;
    userData = [];
end
