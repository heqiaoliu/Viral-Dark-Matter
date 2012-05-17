function indentedText = indentmcode(text)
%INDENTMCODE Helper function for internal use that indents MATLAB code.
%   INDENTMCODE is passed text and it returns text that has been
%   indented according to user's preferences.  The indented text retains
%   the same line separator style as specified by the input text.  Requires
%   Java.
%
%   This file is for internal use only and is subject to change without
%   notice.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $

error(javachk('swing'));
error(nargchk(1,1,nargin));
if ~ischar(text)
    error('MATLAB:INDENTMCODE:NotString', 'The input must be a string.');
end

indentedText = char(com.mathworks.widgets.text.EditorLanguageUtils.indentText(...
    com.mathworks.widgets.text.mcode.MLanguage.INSTANCE, text));
