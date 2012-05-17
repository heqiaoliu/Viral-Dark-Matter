function updateEnable(h,ena)
%updateEnable Update enable state of widget.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/03/09 19:34:24 $

% Enable state is passed in, since this function is called
% by a schema set-function (i.e., the value is not yet
% set in the object)
% ena = h.Enable; % no! not yet set in object

hWidget = h.hWidget;
if ~isempty(hWidget)
    set(hWidget,'Enable',ena);
end

% [EOF]
