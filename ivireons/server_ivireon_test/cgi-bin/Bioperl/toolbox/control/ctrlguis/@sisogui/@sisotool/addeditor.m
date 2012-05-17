function Editor = addeditor(this,EditorClass,idxL)
% Adds new editor to existing SISO Tool

%   Author: P. Gahinet  
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:53:05 $
LoopData = this.LoopData;
% Create editor
Editor = feval(EditorClass,LoopData,idxL);
Editor.initialize(this)
% Activate editor if data has been loaded
if ~isempty(LoopData.Plant)
   activate(Editor)
end
% Add new editor to editor stack
this.PlotEditors = [this.PlotEditors ; Editor];
