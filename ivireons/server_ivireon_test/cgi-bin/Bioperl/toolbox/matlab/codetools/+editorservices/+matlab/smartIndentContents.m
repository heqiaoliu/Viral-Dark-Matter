function smartIndentContents(obj)
%editorservices.smartIndentContents Apply smart indenting to MATLAB code.
%   editorservices.matlab.smartIndentContents(EDITOROBJ) applies smart
%   indenting to the open Editor document associated with EDITOROBJ. The
%   document must contain MATLAB code.
%
%   To apply smart indenting interactively, select Text > Smart Indent in
%   the MATLAB Editor.
%
%   Example: Add code to a new buffer in the Editor, and apply smart
%   indenting.
%
%      newDoc = editorservices.new('% Sample document');
%
%      % Each 10 moves to a new line
%      newDoc.appendText([10 'if true']);
%      newDoc.appendText([10 'disp(''Hello'')']);
%      newDoc.appendText([10 'end']);
%
%      editorservices.matlab.smartIndentContents(newDoc);
%
%   See also editorservices.EditorDocument/appendText, editorservices.EditorDocument/insertText.

% Copyright 2009 The MathWorks, Inc.

checkInput(obj, 'com.mathworks.widgets.text.mcode.MLanguage');

for i=1:numel(obj)
    obj(i).JavaEditor.smartIndentContents;
end
end
