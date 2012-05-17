function codeStrOut = grabcode(filename)
%MATLAB code from M-files published to HTML
%   GRABCODE(FILENAME) extracts the M-code from FILENAME and opens it in the
%   Editor.
%
%   GRABCODE(URL) does the same for any URL.
%
%   OUT = GRABCODE(...) returns the code as a char array, rather than opening
%   the Editor.
%
%   See also PUBLISH.

%   Copyright 1984-2009 The MathWorks, Inc.

% Auto-detect if this is a URL by looking for :// pattern
if strfind(filename,'://')
    % filename is a URL
    fileStr = urlread(filename);
else 
    % filename is a file
    fileStr = file2char(filename);
end

% Normalize line endings.
fileStr = regexprep(fileStr, '\r\n?', '\n');

% Pull out M-code.
matches = regexp(fileStr,'##### SOURCE BEGIN #####\n(.*)\n##### SOURCE END #####','tokens','once');
codeStr = matches{1};
codeStr = strrep(codeStr,'REPLACE_WITH_DASH_DASH','--');

% Return M-code.
if nargout == 0
    editorservices.new(codeStr);
else
    codeStrOut = codeStr;
end
