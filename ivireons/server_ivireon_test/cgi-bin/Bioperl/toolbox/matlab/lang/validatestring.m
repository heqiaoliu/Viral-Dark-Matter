function out = validatestring(in, valid_strings, function_name, ...
                         variable_name, argument_position)
%VALIDATESTRING Check validity of text string.
%   OUT = VALIDATESTRING(IN,VALID_STRINGS,FUNC_NAME,VAR_NAME,ARG_POS) checks 
%   the validity of the text string IN. If the text string matches one of
%   the text strings in the cell array VALID_STRINGS, VALIDATESTRING returns
%   the valid text string in OUT. If the text string does not match, 
%   VALIDATESTRING issues a formatted error message.
%
%   VALIDATESTRING looks for a case-insensitive nonambiguous match between
%   IN and the strings in VALID_STRINGS.
%
%   VALID_STRINGS is a cell array containing text strings.
%
%   FUNC_NAME is a string that specifies the name used in the formatted
%   error message to identify the function checking text strings.
%   FUNC_NAME is an optional argument.
%
%   VAR_NAME is a string that specifies the name used in the formatted
%   error message to identify the argument being checked.  VAR_NAME is an
%   optional argument.
%
%   ARG_POS is a positive integer that indicates the position of the
%   argument being checked in the function argument list. VALIDATESTRING
%   includes this information in the formatted error message.  ARG_POS is
%   an optional argument.
%
%   Example
%   -------
%       % To trigger this error message, define a cell array of some text
%       % strings and pass in another string that isn't in the cell array. 
%       validatestring('option3',{'option1','option2'},'func_name','var_name',2)
%
%   See also validateattributes, inputParser.

%   Copyright 1993-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/03/16 22:18:14 $
