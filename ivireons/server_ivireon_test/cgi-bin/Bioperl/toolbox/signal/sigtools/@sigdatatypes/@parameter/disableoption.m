function disableoption(hObj, option)
%DISABLEOPTION Disable an option from among an enumerated type

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2007/12/14 15:17:51 $

error(nargchk(2,2,nargin,'struct'));

vv = lower(get(hObj, 'AllOptions'));

option = lower(option);

if ~iscellstr(vv) | isempty(strmatch(option, vv)),
    error(generatemsgid('NotSupported'),'Input option not available.');    
end

do = get(hObj, 'DisabledOptions');

% If the option is already disabled, do nothing
indx = strmatch(option, vv);
if length(indx) > 1,
    error(generatemsgid('GUIErr'),'Option name is ambiguous.');
end

set(hObj, 'DisabledOptions', [do, indx]);

% Check to see if we have disabled the current selection.
vv = lower(get(hObj, 'ValidValues'));
v  = lower(get(hObj, 'Value'));

if isempty(strmatch(v,vv)),
    setvalue(hObj, vv{1});
end

% [EOF]
