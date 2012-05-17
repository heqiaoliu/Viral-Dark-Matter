function setstate(hObj, s),
%SETSTATE set the state of the export dialog

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/05/18 02:30:57 $

if isfield(s, 'exportto'),
    news.exporttarget = s.exportto;
    news.overwrite = s.overwritechk;
    s = news;
end

siggui_setstate(hObj, s);

% [EOF]
