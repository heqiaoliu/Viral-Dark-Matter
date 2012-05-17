function buildcurrent(this)
%BUILDCURRENT Build the current design method

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.10.4.4 $  $Date: 2008/04/21 16:31:40 $

hDM          = get(this, 'CurrentDesignMethod');
designmethod = get(this, 'designmethod');
filtertype   = get(this, 'responsetype');

try
    
    
    if ~isempty(designmethod) && ~isempty(filtertype),
        
        % If the current design method matches the new one, do not
        % create a new one
        if ~isempty(hDM) && isempty(find(hDM, '-class', designmethod)) || isempty(hDM)
            hDM = feval(designmethod);
        end
        
        if ~isempty(findprop(hDM, 'responseType')),
            set(hDM, 'responseType', ...
                tag2string(getcomponent(this, '-class', 'siggui.selector', ...
                    'name', 'Response Type'), this.SubType));
        end
        
        % AbortSet is 'Off' so this will always fire, even if we
        % just change the FilterType
        set(this, 'CurrentDesignMethod', hDM);
    end
catch ME %#ok<NASGU>
    % NO OP this is an undo safety valve.
end


% [EOF]
