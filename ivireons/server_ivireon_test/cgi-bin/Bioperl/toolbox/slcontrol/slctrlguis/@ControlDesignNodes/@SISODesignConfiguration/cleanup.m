function cleanup(this) 
% CLEANUP  
%
 
% Author(s): John W. Glass 08-Dec-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2008/03/13 17:39:36 $

delete(this.AutoUpdateListener)

% Remove panels
if ~isempty(this.Dialog)
    javaMethodEDT('removeAll',this.Dialog);
end

% Delete the sisoview if needed
if ishandle(this.sisodb)
    % Clean up the remaining listeners
    this.sisodb.DesignTask.cleanup
    delete(this.sisodb.DesignTask);
    close(this.sisodb);
end