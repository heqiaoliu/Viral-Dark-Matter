function htmlOut = makeHtmlHeader
% Add a head for HTML report file.
%   Use locale to determine the appropriate charset encoding.
%
%   Note: <html> and <head> tags have been opened but not closed. 

% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.6.1.2.1 $

    h1 = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">';
    h2 = '<html xmlns="http://www.w3.org/1999/xhtml">';

    % The character set depends on the language

    locale = feature('Locale');
    % locale.ctype returns charset strings of this form:
    %   ja_JP.Shift_JIS
    %   en_US.windows-1252
    % and so on. We remove language name and territory name to get the
    % appropriate charset.
    encoding = regexprep(locale.ctype,'(^.*\.)','');
    h3 = sprintf('<head><meta http-equiv="Content-Type" content="text/html; charset=%s" />',encoding);

    % Add cascading style sheet link
    cssfile = which('report-styles.css');
    h4 = sprintf('<link rel="stylesheet" href="file:///%s" type="text/css" />',cssfile);

    htmlOut = [h1 h2 h3 h4];
end
