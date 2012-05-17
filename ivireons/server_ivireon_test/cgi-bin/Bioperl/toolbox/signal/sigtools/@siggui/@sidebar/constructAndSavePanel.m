function hPanel = constructAndSavePanel(hSB, index)
%CONSTRUCTANDSAVEPANEL Constructs the panel object and saves it

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:31:20 $

% this will be a private method

hPanel           = getpanelhandle(hSB, index);

if isempty(hPanel),
    
    % If the index is a string, convert to the matching index
    if ischar(index),
        tag   = index;
        index = string2index(hSB, index);
    else
        tag = index2string(hSB, index);
    end
    
    % Get all the constructors
    constructors     = get(hSB,'Constructors');

    % FEVAL the indexed constructor
    hPanel           = feval(constructors{index}, hSB);
    
    p = schema.prop(hPanel, 'sidebar_tag', 'string');
    set(hPanel, 'sidebar_tag', tag);
    set(p, 'AccessFlags.PublicSet', 'Off', 'AccessFlags.PublicGet', 'Off');
    
    addcomponent(hSB, hPanel);

end


% [EOF]
