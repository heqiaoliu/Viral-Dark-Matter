function password = readPassword(prompt)
; %#ok Undocumented
%readPassword - prompt the user for a password on the command line.
%   Allows to prompt the user for sensitive data (e.g., a password): user
%   input does not get echoed to stdout and not stored in the command
%   history. Apparently, this only works for Unix platforms (Windows always
%   uses the graphical dialogs).
%   This function returns the password string or in case of failure a Java
%   exception containing the error message.

% Copyright 2010 The MathWorks, Inc.

fprintf(prompt);

if ispc
    % Note: this is echoing the user input back onto stdout. We never
    %       expect this method to be used on Windows.
    command = 'cmd /v:on /c "set /p pass= && echo !pass!"';
    newline = false;
else
    command = '/bin/sh -c ''read -s password; echo $password''';
    newline = true;
end
[status, output] = system(command);
if newline
    fprintf('\n');
end
if status == 0
    rawPassword = regexprep(output, '\n', '');
    password = iProcessBackspaces(rawPassword);
else
    message = 'Reading password failed.';
    if ~isempty(output)
        message = [message ' Reason: ' output];
    end
    password = java.lang.Exception(message);
end
end

% -------------------------------------------------------------------------
% processBackspaces
% -------------------------------------------------------------------------
% Removes the backspaces and backspaced characters from a character array.
function noBackspaces = iProcessBackspaces(maybeBackspaces)

%short circuit if there are no backspaces
backspaceChar = char(8);

if all (maybeBackspaces ~= backspaceChar)
    noBackspaces = maybeBackspaces;
    return
end

noBackspaces = blanks(length(maybeBackspaces));

%next index to insert at
index = 1;
for rawIndex = 1:length(maybeBackspaces)
    
    %if this is a backspace
    if strcmp(backspaceChar,maybeBackspaces(rawIndex))
        %if there's something to backspace over
        if index > 1
            %move back one character
            index = index - 1;
        end
        %else ignore the backspace because there's nothing to the left
    else
        %put the character in the next spot and advance the index
        noBackspaces(index) = maybeBackspaces(rawIndex);
        index = index +1;
    end
end
if index > 1
    noBackspaces = noBackspaces(1:index-1);
else
    noBackspaces = '';
end
end
