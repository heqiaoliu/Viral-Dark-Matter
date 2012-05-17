function str = cr_parser(this, str, num)
%CR_PARSER Parser for the CR methods.
%   H.CR_PARSER(STR) Parse STR and add [] in between all strings.  This is
%   the format that ADD expects to know when to add carriage returns.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/03/02 10:26:33 $

if nargin < 3, num = 1; end

spacing = repmat({[]}, 1, num);

indx = 1;
while indx < length(str)
    if ischar(str{indx}) && ~isempty(str{indx+1})
        str = {str{1:indx} spacing{:} str{indx+1:end}};
        indx = indx + 1;
    end
    indx = indx + 1;
end

% [EOF]
