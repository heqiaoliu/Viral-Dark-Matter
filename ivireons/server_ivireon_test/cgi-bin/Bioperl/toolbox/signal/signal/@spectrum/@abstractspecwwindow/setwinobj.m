function hwinObj = setwinobj(this,hwinObj)
% SETWINOBJ Sets the window property (object) of the response object.

%   Author(s): P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/07/14 06:44:57 $

if isempty(hwinObj),
    return;
end

p = get(this, 'WindowParameters');
if ~isempty(this.Window)

    % Get a list of the properties added by the old window.
    props2remove = propstoaddtospectrum(this.Window);

    % Cache all of the old values in the WindowParameters structure.
    for indx = 1:length(props2remove)
        p.(props2remove{indx}) = this.(props2remove{indx});
    end
    set(this, 'WindowParameters', p);
end

% Remove the properties for the old window.
rmprops(this, this.Window);

% If there are no propstoadd, do nothing
props2add = propstoaddtospectrum(hwinObj);
if ~isempty(props2add),
    
    % Add the properties from the window object to the spectrum.
    hp = addprops(this,hwinObj,props2add{:});

    % Check if any of the properties that we have added for this window
    % have previously been added to the spectrum object.
    for indx = 1:length(props2add)
        if isfield(p, props2add{indx})
            set(this, props2add{indx}, p.(props2add{indx}));
        end
    end
end

% [EOF]
