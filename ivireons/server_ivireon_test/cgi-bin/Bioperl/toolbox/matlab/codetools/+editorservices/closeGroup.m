function closeGroup
%editorservices.closeGroup() Close Editor and all open documents. 
%   editorservices.closeGroup() closes the MATLAB Editor and all of its 
%   open documents, discarding any unsaved changes in the documents.
%   Closing the Editor invalidates any existing EditorDocument objects.
%
%   Example: Close any open files in the Editor.
%
%      allDocs = editorservices.getAll;
%      if ~isempty(allDocs)
%          editorservices.closeGroup;
%      end
%
%   See also editorservices.EditorDocument/close, editorservices.EditorDocument/closeNoPrompt, editorservices.EditorDocument. 

% Copyright 2009 The MathWorks, Inc.

jea = editorservices.EditorUtils.getJavaEditorApplication;
jea.closeNoPrompt;

end

