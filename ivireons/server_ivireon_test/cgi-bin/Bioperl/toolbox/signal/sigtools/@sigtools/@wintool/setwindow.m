function setwindow(hWT, newwins)
%SETWINDOW 

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2008/08/01 12:25:54 $

% Default window
hManag = getcomponent(hWT, '-class', 'siggui.winmanagement');

% Add windows
for i = 1:length(newwins),
    if isa(newwins(i), 'sigwin.window'),
        hSpecsDefault = hManag.defaultwindow;
        hSpecsDefault.Window = newwins(i);
        hSpecsDefault.Data = generate(newwins(i));
        hSpecsDefault.Length = int2str(newwins(i).Length);
        addnewwin(hManag, hSpecsDefault);
    end
end


% [EOF]
