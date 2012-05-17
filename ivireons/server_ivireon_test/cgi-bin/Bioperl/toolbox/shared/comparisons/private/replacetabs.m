function codeOut = replacetabs(codeIn,offset)
% Substitute spaces for tabs in code to appear as HTML
%   codeOut = replaceTabsInCode(codeIn)
%   codeOut = replaceTabsInCode(codeIn,offset)
%
% codeIn is a string which may contain tabs.
% codeOut is a string in which tabs are replaced with spaces such that the
%   next character is at a "tab stop".  The distance between tab stops is
%   determined by the MATLAB Editor Preferences.
%
% If the supplied string does not start at the beginning of the line, an
% offset can be specified.  This is the number of characters in the line
% before the supplied string, and is used to calculate the position of the
% tab stops relative to the supplied string.

% Copyright 1984-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $

    if nargin<2
        offset = 0;
    end
    % Get the number of spaces per tab based on the MATLAB Editor's preferences
    spacesPerTab = com.mathworks.widgets.text.EditorPrefsAccessor.getSpacesPerTab();
    tabChar = sprintf('\t');

    codeOut = codeIn;

    tabIndex = find(codeOut==tabChar);
    while ~isempty(tabIndex)
        % Add enough spaces to take us to the next even multiple of spacesPerTab
        numSpaces = spacesPerTab - rem(tabIndex(1)+offset,spacesPerTab) + 1;
        codeOut = regexprep(codeOut,'\t',char(32*ones(1,numSpaces)),'once');
        tabIndex = find(codeOut==tabChar);
    end
end

