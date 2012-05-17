function displayLoadingMessage( reportName )
%
%   This function is unsupported and might change or be removed without
%   notice in a future version.

%DISPLAYLOADINGMESSAGE displays the loading... in the web browser for a
%directory report

% Copyright 2009 The MathWorks, Inc.

header = ['<head><title>' reportName '</title></head>'];
message = ['text://<html>' header '<body>'...
    sprintf('Generating %s...', reportName)...
    '</body></html>'];
web(message,'-noaddressbox');

end

