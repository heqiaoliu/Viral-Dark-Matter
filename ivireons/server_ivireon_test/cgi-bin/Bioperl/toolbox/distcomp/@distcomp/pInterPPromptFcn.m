function pInterPPromptFcn
; %#ok Undocumented

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2007/11/09 19:49:53 $

% Call the necessary functions for checking communication mismatches
mpigateway('setidle'); 
mpigateway('setrunning');
% Ensure that for:drange state is reset
parfor_depth(0);