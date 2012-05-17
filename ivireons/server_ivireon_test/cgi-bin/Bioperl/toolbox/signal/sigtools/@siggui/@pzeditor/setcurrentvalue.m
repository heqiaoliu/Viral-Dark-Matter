function setcurrentvalue(hObj, cv)
%SETCURRENTVALUE Set the value of the current pole/zero

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2007/12/14 15:19:13 $

error(nargchk(2,2,nargin,'struct'));

hc = get(hObj, 'CurrentRoots');

if isempty(hc),
    warning(generatemsgid('noPoleZeroSelected'), 'There is no pole or zero currently selected');
else
    setvalue(hc, cv);
end

% [EOF]
