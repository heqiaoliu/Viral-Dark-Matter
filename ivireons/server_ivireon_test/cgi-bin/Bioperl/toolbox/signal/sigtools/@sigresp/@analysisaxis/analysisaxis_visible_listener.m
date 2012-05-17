function analysisaxis_visible_listener(this, eventData)
%ANALYSISAXIS_VISIBLE_LISTENER Make sure that the title is visible off.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/12/26 22:22:51 $

siggui_visible_listener(this, eventData);

if strcmpi(get(this, 'Visible'), 'on'),

    ht = get(getbottomaxes(this), 'Title');
    
    set(ht, 'Visible', get(this, 'Title'));

    updatelegend(this);
end

% [EOF]
