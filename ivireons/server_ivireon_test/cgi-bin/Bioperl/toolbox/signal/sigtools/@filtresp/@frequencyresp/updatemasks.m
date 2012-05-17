function updatemasks(hObj)
%UPDATEMASKS Draw the masks onto the bottom axes

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.5.4.3 $  $Date: 2009/01/05 17:59:58 $

h = get(hObj, 'Handles');

if isfield(h, 'masks')
    h.masks(~ishghandle(h.masks)) = [];
    delete(h.masks);
end

if strcmpi(hObj.DisplayMask, 'On'),
    
    Hd = hObj.Filters;
    
    fs = Hd.Fs;
    mi = Hd.Filter.MaskInfo;
    if isempty(fs) || strcmpi(hObj.NormalizedFrequency, 'on'),
        fs = 2;
        mi.frequnit = 'Hz'; % Fool it into using 2 Hz so it looks normalized
    end
        
    % Convert the frequency depending on the new frequency.    
    for indx = 1:length(mi.bands),
        mi.bands{indx}.frequency = mi.bands{indx}.frequency*fs/mi.fs;
    end
    mi.fs = fs;
    
    h.masks = info2mask(mi, getbottomaxes(hObj));
    set(h.masks, 'HitTest', 'off');
    set(hObj, 'Handles', h);
end

% [EOF]
