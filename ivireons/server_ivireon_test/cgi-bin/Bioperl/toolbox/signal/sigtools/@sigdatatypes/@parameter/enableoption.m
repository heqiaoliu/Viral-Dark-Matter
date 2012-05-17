function enableoption(hObj, option)
%ENABLEOPTION Enable an option from among an enumerated type

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2007/12/14 15:17:52 $

vv = lower(get(hObj, 'AllOptions'));
option = lower(option);

if ~iscellstr(vv) | isempty(strmatch(option, vv)),
    error(generatemsgid('NotSupported'),'Input option not available.');    
end

do = get(hObj, 'DisabledOptions');

set(hObj, 'DisabledOptions', setdiff(do, strmatch(option, vv)));

% [EOF]
