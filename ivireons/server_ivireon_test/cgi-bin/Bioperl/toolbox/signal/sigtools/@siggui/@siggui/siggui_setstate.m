function siggui_setstate(hObj,s)
%SIGGUI_SETSTATE Set the state of the object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2007/12/14 15:19:56 $

error(nargchk(2,2,nargin,'struct'));

if isfield(s, 'Tag'),  s = rmfield(s, 'Tag'); end
if isfield(s, 'Version'),  s = rmfield(s, 'Version'); end

if ~isempty(s),
    set(hObj, s);
end

% [EOF]
