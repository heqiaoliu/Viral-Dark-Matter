function hPanel = getpanelhandle(hSB, index)
%GETPANELHANDLE Returns the specified Panel Handle
%   GETPANELHANDLE(hSB,INDEX) Returns the panel handle specified by INDEX in
%   the sidebar object.  If the panel handle has not been instantiated
%   GETPANELHANDLE will return 0.
%
%   GETPANELHANDLE(hSB,LABEL) Returns the panel handle whose label is LABEL.

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2008/04/21 16:31:44 $



if index == 0,
    hPanel = [];
else
    
    try,
        % If the index is a string convert to matching index
        if isnumeric(index),
            str = index2string(hSB, index);
        else
            str = index;
            index = string2index(hSB, str);
        end
        
        cons = get(hSB, 'Constructor');
        
        if isstruct(cons{index}),
            hPanel = cons{index};
        else
            hPanel = getcomponent(hSB, 'sidebar_tag', str);
        end
    catch ME %#ok<NASGU>
        
        % Not installed
        hPanel = 0;
    end
    
end

% [EOF]
