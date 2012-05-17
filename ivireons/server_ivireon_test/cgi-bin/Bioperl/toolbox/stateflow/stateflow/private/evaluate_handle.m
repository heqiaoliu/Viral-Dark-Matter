function hdls = evaluate_handle (ids)
% This is used by "Send to Workspace" ctxmenu option
% DONT REMOVE THIS

% Copyright 2002-2007 The MathWorks, Inc.
%   $Revision: 1.1.4.4 $  $Date: 2007/09/21 19:16:20 $
  
  hdls = [];   
  
  try
    for id=[ids]
        hdls = [hdls; idToHandle(sfroot, id)];
    end
  catch
    % do nothing on error!
  end
  
  

