function showGeneratedMATLABCode(str)
% SHOWGENERATEDMATLABCODE
 
% Author(s): John W. Glass 28-Jul-2008
% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2009/09/09 21:43:19 $

mcode_str = [];
for n = 1:length(str)
    mcode_str = [mcode_str,str{n},sprintf('\n')];
end

% Throw to command window if java is not available
err = javachk('mwt','The MATLAB Editor');
if ~isempty(err)
    local_display_mcode(mcode_str,'cmdwindow');
end
% Convert to char array, add line endings
editorDoc = editorservices.new(mcode_str);
editorservices.matlab.smartIndentContents(editorDoc);

% Scroll document to line 1
editorDoc.goToLine(1);

