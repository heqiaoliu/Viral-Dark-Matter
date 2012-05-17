function  activeEditor  = getActive
%editorservices.getActive() Find active (topmost) Editor document.
%   EDITOROBJ = editorservices.getActive() returns an EditorDocument object
%   associated with the active document in the MATLAB Editor (that is, the
%   topmost buffer in the group). The active document is not always
%   associated with a saved file.
%
%   Example: Determine which open document in the Editor is active.
%
%      allDocs = editorservices.getAll;
%      if ~isempty(allDocs)
%          activeDoc = editorservices.getActive
%      end
%
%   See also editorservices.EditorDocument, editorservices.find, editorservices.getAll, editorservices.open.

% Copyright 2009 The MathWorks, Inc.

activeEditor = editorservices.EditorDocument.getActiveEditor;

end

