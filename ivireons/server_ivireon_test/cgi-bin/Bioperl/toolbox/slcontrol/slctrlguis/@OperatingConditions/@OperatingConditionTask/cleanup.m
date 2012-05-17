function cleanup(this)
% CLEANUP
%
 
% Author(s): John W. Glass 12-Dec-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2008/03/13 17:40:29 $

% Clean up panels
if ~isempty(this.Dialog)
    javaMethodEDT('clearPane',this.Dialog.getOpCondSpecPanel);
end

if ~isempty(this.MenuBar)
    javaMethodEDT('dispose',this.MenuBar);
    this.MenuBar = [];
end

if ~isempty(this.ToolBar)
    javaMethodEDT('dispose',this.ToolBar);
    this.ToolBar = [];
end