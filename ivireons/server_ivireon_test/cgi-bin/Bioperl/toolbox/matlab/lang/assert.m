%ASSERT Generate an error when a condition is violated.
%   ASSERT(EXPRESSION) evaluates EXPRESSION and, if it is false, displays the
%   error message 'Assertion Failed'.
%
%   ASSERT(EXPRESSION, ERRMSG) evaluates EXPRESSION and, if it is false,
%   displays the string contained in ERRMSG. When ERRMSG is the last input to
%   ASSERT, MATLAB displays it literally, without performing any substitutions
%   on the characters in ERRMSG.
%
%   ASSERT(EXPRESSION, ERRMSG, VALUE1, VALUE2, ...) evaluates EXPRESSION and, if
%   it is false, displays the formatted string contained in ERRMSG. The ERRMSG
%   string can include escape sequences such as \t or \n as well as any of the C
%   language conversion specifiers supported by the SPRINTF function (e.g., %s
%   or %d). Additional arguments VALUE1, VALUE2, etc. provide values that
%   correspond to the format specifiers and are only required when the ERRMSG
%   string includes conversion specifiers.
%
%   MATLAB makes substitutions for escape sequences and conversion specifiers in
%   ERRMSG in the same way that it does for the SPRINTF function. Type HELP SPRINTF
%   for more information on escape sequences and format specifiers.
%
%   ASSERT(EXPRESSION, MSG_ID, ERRMSG, VALUE1, VALUE2, ...) evaluates EXPRESSION
%   and, if it is false, displays the formatted string ERRMSG as in the
%   paragraph above. This syntax also tags the error with the message identifier
%   contained in MSG_ID.  A message identifier is a string of the form
%
%      <component>[:<component>]:<mnemonic>,
%
%   where <component> and <mnemonic> are alphanumeric strings (for example,
%   'MATLAB:AssertionFailed').
%
%   See also error, sprintf

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/11 22:44:17 $
