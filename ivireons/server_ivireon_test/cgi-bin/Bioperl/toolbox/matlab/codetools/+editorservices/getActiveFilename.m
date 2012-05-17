function  activeEditorFilename  = getActiveFilename
%editorservices.getActiveFilename() Find name of file for active document.
%   FILENAME = editorservices.getActiveFilename() returns the full path of
%   the file associated with the active document in the MATLAB Editor. 
%   For unsaved documents, FILENAME is 'Untitled' or 'UntitledN', where N
%   is an integer. If no documents are open, FILENAME is an empty string.
%
%   Example: Change the current folder to the one that contains the active 
%   document in the Editor.
%
%      currentFile = editorservices.getActiveFilename;
%      if ~isempty(currentFile)
%          desiredDir = fileparts(currentFile);
%          cd(desiredDir);
%      end
%
%   See also editorservices.EditorDocument, editorservices.EditorDocument.Filename, editorservices.find, editorservices.getActive.

% Copyright 2009 The MathWorks, Inc.

activeEditor = editorservices.getActive;
if isempty(activeEditor)
    activeEditorFilename = '';
else
    activeEditorFilename = activeEditor.Filename;
end

end

