function hideBodyContentIfTooSmall(dp)
% Optionally hide BodyPanel if dimensions are too small

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $   $Date: 2010/04/21 21:48:57 $

% hBodyTooSmallTxt
% BodyMinWidth = 0 % pixels
% BodyMinHeight = 0 % pixels
% BodyMinSizeTitle = 'application' % name of application for message

bodyPos = get(dp.hBodyPanel,'pos');

minWidth = dp.BodyMinWidth;
minHeight = dp.BodyMinHeight;
if minWidth>0 || minHeight>0
    tooNarrow = bodyPos(3) < minWidth;
    tooShort = bodyPos(4) < minHeight;
    if ~tooNarrow && ~tooShort
        % Keep body visible
        set(dp.hBodyTooSmallTxt,'vis','off');
        set(dp.hBodyPanel,'vis','on');
        
        return % EARLY EXIT
        
    elseif tooNarrow && tooShort
        sizStr = DAStudio.message('Spcuilib:dialogmgr:SmallDisplay');
    elseif tooShort
        sizStr =  DAStudio.message('Spcuilib:dialogmgr:ShortDisplay');
    else % tooNarrow
        sizStr = DAStudio.message('Spcuilib:dialogmgr:NarrowDisplay');
    end
    
    % Make body invisible, then update "too small" message
    % NOTE: message may be invisible when initially updated
    msg = DAStudio.message('Spcuilib:dialogmgr:DisplayTooSmallMsg',sizStr,lower(dp.BodyMinSizeTitle));
    set(dp.hBodyPanel,'vis','off'); % hide body content first
    set(dp.hBodyTooSmallTxt,'string',msg); % then show msg - may be hidden
    
    % Test dimension of "too small" msg
    ext = get(dp.hBodyTooSmallTxt,'ext');
    if bodyPos(3) <= ext(3) || bodyPos(4) <= ext(4);
        % Body is too narrow or short even for our
        % warning message to display
        set(dp.hBodyTooSmallTxt,'vis','off');
    else
        % Show msg
        % Compute position of message
        x = bodyPos(1)+(bodyPos(3)-ext(3))/2; % x coord to start message
        y = bodyPos(2)+(bodyPos(4)-ext(4))/2;
        set(dp.hBodyTooSmallTxt, ...
            'pos',[x y ext(3:4)], ...
            'vis','on');
    end
end

