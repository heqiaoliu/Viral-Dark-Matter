function updateOverflowTextAndXPos(ntx)
% Update overflow text next to overflow threshold cursor

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $     $Date: 2010/05/20 02:18:07 $

[binCnt,binPct] = getTotalOverflows(ntx);
htOver = ntx.htOver;

if binCnt==0
    % If there is no overflow, suppress the text
    if ~isempty(get(htOver,'string'))
        % Turning off string - update the Yaxis limit so
        % bargraph might get taller
        set(htOver,'string','');
        
        % Minimal update of display
        setYAxisLimits(ntx);
        updateXAxisTextPos(ntx);
        updateDTXTextAndLinesYPos(ntx);
    end
else
    % Check to see if we are changing from no underflow to underflow
    % This indicates a rescaling in Y may be needed
    updateY = isempty(get(htOver,'string'));
    
    if ntx.HistVerticalUnits==1
        % Bin Percentage
        str = sprintf('%.1f%%\noutside\nrange',binPct);
    else
        % Bin Count
        if binCnt==1
            str = sprintf('%d\noutside\nrange',binCnt);
        else
            str = sprintf('%d\noutside\nrange',binCnt);
        end
    end
    psave = get(htOver,'pos');
    set(htOver, ...
        'units','data', ...
        'string',str); % set early to get extent
    ext = get(htOver,'extent');
    strWidth = ext(3); % string width in x-axis data units
    pos = get(htOver,'pos');
    
    % Determine distances from underflow cursor ...
    xthresh = ntx.LastOver;
    xref = max(ntx.RadixPt, ntx.LastUnder); % radix line or underflow
    xlim = get(ntx.hHistAxis,'xlim');
    distToLeft = abs(xthresh-xlim(2)); % ... to max axis limit
    distToRight = abs(xthresh-xref);   % ... to histogram center or under-thresh
    if (strWidth < distToLeft) || (strWidth > distToRight)
        % Move text to LEFT of cursor (preferred)
        pos(1) = xthresh-ntx.BarGapCenter;
        horz = 'right';
        xtAdj = -1.5;
        % an opaque white background could show through to axis
        if xthresh < ntx.RadixPt
            backgr = get(ntx.hHistAxis,'color');
        else
            backgr = 'none';
        end
    else
        % Move text to RIGHT of cursor
        pos(1) = xthresh-ntx.BarGapCenter;
        horz = 'left';
        xtAdj = 1.5;
        % Use opaque white to "cut through" radix line
        backgr = get(ntx.hHistAxis,'color');
    end
    set(htOver, ...
        'pos',pos, ...
        'backgr',backgr, ...
        'horiz',horz);
    set(htOver,'units','char');
    
    % fix for y wander bug
    pos = get(htOver,'pos');
    pos(1) = pos(1) + xtAdj;  % gutter spacing
    pos(2) = psave(2);
    set(htOver,'pos',pos);
    
    if updateY
        % Minimal update of display
        setYAxisLimits(ntx);
        updateXAxisTextPos(ntx);
        updateDTXTextAndLinesYPos(ntx);
    end
end
