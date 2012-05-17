function strs = strdisp(strs)
% STRDISP Cleans up a string or a cell array of strings of newline/linefeed
% characters for display purposes.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/11/09 20:59:35 $

if ischar(strs) || iscellstr(strs)
  % Remove newline and return characters.
  strs = regexprep( strs, '\n\r?', ' ' );
else
  ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidInputArguments' );
end
