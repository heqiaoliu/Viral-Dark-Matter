function editorObj = openAndGoToLine(filename, lineNumber)
%editorservices.openAndGoToLine Open file and highlight specified line.
%   EDITOROBJ = editorservices.openAndGoToLine(FILENAME, LINENUM) opens the
%   file FILENAME in the MATLAB Editor, highlights the specified line, and
%   creates an EditorDocument object. FILENAME must include the full path.
%   If the file is already open, the openAndGoToLine function makes the 
%   document active.
%
%   Example: Open the file Contents.m and highlight line 50.
%
%      contents = editorservices.openAndGoToLine( ...
%                    which('Contents.m'), 50);
%
%   See also editorservices.open, editorservices.openAndGoToFunction, editorservices.EditorDocument/goToLine.

%  Copyright 2009 The MathWorks, Inc.

editorObj = editorservices.open(filename);
editorObj.goToLine(lineNumber);

end