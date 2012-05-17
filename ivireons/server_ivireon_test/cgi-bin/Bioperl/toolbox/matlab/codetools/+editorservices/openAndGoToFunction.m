function editorObj = openAndGoToFunction(filename, functionname)
%editorservices.openAndGoToFunction Open MATLAB file and highlight function.
%   EDITOROBJ = editorservices.openAndGoToFunction(FILENAME, FUNCTION)
%   opens the file FILENAME in the MATLAB Editor, highlights the first
%   occurrence of the specified function, and creates an EditorDocument 
%   object. The file must contain MATLAB code. FILENAME must include the 
%   full path. If the file is already open, openAndGoToFunction makes the 
%   document active.
%
%   If openAndGoToFunction cannot find the file or the function, it throws 
%   an exception.
%
%   Example: Open taxdemo.m and highlight the computeTax function.
%
%      taxDoc = editorservices.openAndGoToFunction(...
%                  which('taxdemo.m'), 'computeTax');
%
%   See also editorservices.matlab.goToFunction, editorservices.open, editorservices.openAndGoToLine.

%  Copyright 2009 The MathWorks, Inc.

editorObj = editorservices.open(filename);
editorservices.matlab.goToFunction(editorObj, functionname);

end