function evaluate_handle_in_base_ws (id)
% Copyright 2002-2007 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2007/09/21 19:16:22 $
% This is used by "Send to Workspace" ctxmenu option
% DONT REMOVE THIS
   try
       cmd = sprintf('sf(''Private'', ''evaluate_handle'', %d)', id);
       evalin('base', cmd);
   catch
       % do nothing
   end

