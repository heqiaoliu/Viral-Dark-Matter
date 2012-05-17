function cleanup(this)
% CLEANUP
%
 
% Author(s): John W. Glass 12-Dec-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2007/02/06 19:50:19 $

% Remove panels
if ~isempty(this.Dialog)
    awtinvoke(this.Dialog,'removeAll()');
end

% Delete the sisoview if needed
if ishandle(this.sisodb)
    % Clean up the remaining listeners
    this.sisodb.DesignTask.cleanup
    delete(this.sisodb.DesignTask);
    close(this.sisodb);
end