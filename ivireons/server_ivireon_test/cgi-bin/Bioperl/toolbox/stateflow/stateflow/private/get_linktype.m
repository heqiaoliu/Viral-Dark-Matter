function type = get_linktype(id)
% Given a Stateflow.LinkChart object, determine which type
% we are actually linked to.  
% Could be 'eml' 'truthtable' 'sf' or 'unknown'

% Copyright 2005-2008 The MathWorks, Inc.


type = 'unknown';

try
    rt = sfroot;
    obj = rt.idToHandle(id);
    ss = obj.up;
    dispstr = ss.MaskDisplay;

    % We are relying on the block's 'MaskDisplay' property to
    % determine the type.  The following are regexp patterns
    % that appear in only the corresponding type.
    
    % Note that if the MaskDisplays ever change, this code 
    % may break.
    emlstr = 'fcn';
    ttstr = 'NaN';
    sfstr = 'sf';

    if(~isempty(regexp(dispstr, emlstr, 'once')))
        type = 'eml';
    elseif (~isempty(regexp(dispstr, ttstr, 'once')))
        type = 'truthtable';
    elseif (~isempty(regexp(dispstr, sfstr, 'once')))
        type = 'stateflow';
    end
catch
end
