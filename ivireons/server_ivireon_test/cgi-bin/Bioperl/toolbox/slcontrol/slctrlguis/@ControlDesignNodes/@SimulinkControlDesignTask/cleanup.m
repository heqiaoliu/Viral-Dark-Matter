function cleanup(this)
% CLEANUP  Enter a description here!
%
 
% Author(s): John W. Glass 12-Dec-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2008/03/13 17:39:41 $

% Clean up the block tree
delete(this.BlockTree);
delete(this.SignalTree);

if ~isempty(this.MenuBar)
    javaMethodEDT('dispose',this.MenuBar);
    this.MenuBar = [];
end

if ~isempty(this.ToolBar)
    javaMethodEDT('dispose',this.ToolBar);
    this.ToolBar = [];
end