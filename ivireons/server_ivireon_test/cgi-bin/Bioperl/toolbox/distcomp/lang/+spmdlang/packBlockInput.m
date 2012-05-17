function p = packBlockInput( Q )
%packBlockInput - prepare data or Remotes for transmission to the labs.
% This method is called by the SPMD infrastructure to prepare input data
% used by an SPMD block.
    
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2008/05/19 22:46:17 $

    if isa( Q, 'spmdlang.AbstractRemote' )
        p = packForTransmission( Q );
    else
        % Simply send the raw data to the block.
        p = Q;
    end
end
