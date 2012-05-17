function updateUnderflowTextAndXPos(ntx)
% Update underflow text next to underflow threshold cursor

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $     $Date: 2010/05/20 02:18:09 $

[binCnt,binPct] = getTotalUnderflows(ntx);
htUnder = ntx.htUnder;

if binCnt==0 % or binPct==0 ... same outcome
    % If there is no underflow, suppress the text
    if ~isempty(get(ntx.htUnder,'string'))
        set(htUnder,'string','');
        
        % Minimal update of display
        setYAxisLimits(ntx);
        updateXAxisTextPos(ntx);
        updateDTXTextAndLinesYPos(ntx);
    end
else
    % Check to see if we are changing from no underflow to underflow
    % This indicates a rescaling in Y may be needed
    updateY = isempty(get(htUnder,'string'));
    
    if ntx.HistVerticalUnits==1
        % Bin Percentage
        str = sprintf('%.1f%%\nbelow\nprecision',binPct);
    else
        % Bin Count
        if binCnt==1
            str = sprintf('1\nbelow\nprecision');
        else
            str = sprintf('%d\nbelow\nprecision', binCnt);
        end
    end
    set(htUnder,'units','char');
    psave = get(htUnder,'pos');
    set(htUnder, ...
        'units','data', ...
        'string',str); % set early to get extent
    
    ext = get(htUnder,'extent');
    strWidth = ext(3); % string width in x-axis data units
    pos = get(htUnder,'pos'); % current text position
    
    % Determine distances from underflow cursor to min x-axis limit
    xlim = get(ntx.hHistAxis,'xlim');
    xthresh = ntx.LastUnder;
    distToLeft = min(ntx.RadixPt,ntx.LastOver) - xthresh;
    distToRight = xthresh - xlim(1);
    
    if (strWidth < distToRight) || (strWidth > distToLeft)
        % Move text to RIGHT of under-thresh (preferred)
        pos(1) = xthresh-ntx.BarGapCenter;
        horz = 'left';
        xtAdj = +2.0;  % gutter space
        
        % an opaque background could show through to axis
        % a white background will "cut through" radix line
        if xthresh > ntx.RadixPt
            backgr = get(ntx.hHistAxis,'color');
        else
            backgr = 'none';
        end
    else
        % Move text to LEFT of under-thresh cursor
        pos(1) = xthresh-ntx.BarGapCenter;
        horz = 'right';
        xtAdj = -0.5; % gutter space
        backgr = 'none';
    end
    set(htUnder, ...
        'pos',pos, ...
        'backgr',backgr, ...
        'horiz',horz);
    
    % fix wander, add gutter space
    set(htUnder,'units','char');
    pos = get(htUnder,'pos');
    pos(2) = psave(2); % fix wander bug
    pos(1) = pos(1) + xtAdj;
    set(htUnder,'pos',pos);
    
    if updateY
        % Minimal update of display
        setYAxisLimits(ntx);
        updateXAxisTextPos(ntx);
        updateDTXTextAndLinesYPos(ntx);
    end
end
