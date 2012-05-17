function obj = new(bufferText)
%editorservices.new() Create document in Editor. 
%   EDITOROBJ = editorservices.new() returns an EditorDocument object
%   associated with a new, empty Editor buffer.
%
%   EDITOROBJ = editorservices.new(TEXT) opens a new buffer that contains
%   the specified TEXT.
%
%   Example: Create a document in the Editor.
%
%      newDoc = editorservices.new('% My test document');
%
%   See also editorservices.EditorDocument/appendText, editorservices.EditorDocument, editorservices.find, editorservices.open, editorservices.EditorDocument/insertText.

% Copyright 2008-2009 The MathWorks, Inc.

if nargin < 1
    bufferText = '';
end

obj = editorservices.EditorDocument.new(bufferText);

end


