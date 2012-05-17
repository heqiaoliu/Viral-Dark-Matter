function pctPreRemoteEvaluation( type )
; %#ok Undocumented

% This function is called prior to execution of either parfor or spmd to
% ensure the workers are in the correct state.

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2008/06/24 17:00:30 $

   % Ensure that we use the correct MPI functionality for this parfor/spmd
   dctRegisterMpiFunctions( type );
   
   % Ensure that we have picked up any changes to the path before
   % deserialization - this ensures that files created or changed after the
   % pool was opened are correctly interpreted
   rehash;
end
