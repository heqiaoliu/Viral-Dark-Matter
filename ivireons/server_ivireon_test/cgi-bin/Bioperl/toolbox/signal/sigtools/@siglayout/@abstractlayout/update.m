function update(this, force)
%UPDATE   Update the layout.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/10/18 21:10:57 $

if nargin < 2
    force = 'noforce';
end

% When UPDATE is called, we assume the layout is dirty.
if this.Invalid || strcmpi(force, 'force')
    
    % Nothing to do if the panel is invisible, to avoid multiple updates.
    if strcmpi(get(this.Panel, 'Visible'), 'Off')
        return;
    end

    layout(this);
    
    % The layout is now clean.
    set(this, 'Invalid', false);
end

% [EOF]
