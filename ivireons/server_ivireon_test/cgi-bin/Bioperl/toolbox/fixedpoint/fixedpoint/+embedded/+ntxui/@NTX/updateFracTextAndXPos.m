function updateFracTextAndXPos(ntx)
% Update fraction-size text and x-position
% Options:
%   1 = Fraction length
%   2 = Scale factor

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $     $Date: 2010/05/20 02:18:06 $

dlg = ntx.hBitAllocationDialog;

% Don't include extra bits in fracBits, we call them out separately
[~,fracBits] = getWordSize(ntx);

xq = ntx.LastUnder;
ena = extraLSBBitsSelected(dlg);

if ntx.DTXFracSpanText==1 % Percent display
    if ena
        % Show summation of extra bits separately
        % Show extra bits in gray italics
        s1 = sprintf('FL=%d',fracBits);
        s2 = sprintf('%d',dlg.BAFLExtraBits);
        str = [s1 '\color{gray}\it+' s2];
        %str = sprintf('FL=%d\color{gray}\it+%d',fracBits,dlg.BAFLExtraBits);
    else
        str = sprintf('FL=%d',fracBits);
    end
    vert = 'top';
    
else % Count display
    if ena
        % Show summation of extra bits separately in exponent
        % str = sprintf('Slope=2^{%d%+d}',-fracBits,-dlg.BAFLExtraBits);
        %
        % Show total sum, with no break-out of extra bits
        str = sprintf('Slope=2^{%d}',-fracBits-dlg.BAFLExtraBits);
    else
        str = sprintf('Slope=2^{%d}',-fracBits);
    end
    vert = 'cap';  % to keep "2^N" in alignment with "IL"
end
% Initial setup of text to get actual text extent
psave = get(ntx.htFracSpan,'pos');
set(ntx.htFracSpan, ...
    'vert',vert, ...
    'units','data', ...
    'string',str);

% Adjust fraction-size text position
pos = get(ntx.htFracSpan,'pos');
radixPt = ntx.RadixPt;

% Check if underflow line is past radix line
underflowPastRadix = xq > radixPt;
if underflowPastRadix
    placeToSide = true;
else
    % Compare string width to distance from underflow cursor to radix line
    ext = get(ntx.htFracSpan,'extent');
    strWidth = ext(3); % string width in x-axis data units
    ref = min(radixPt,ntx.LastOver);
    placeToSide = (strWidth*1.1 > ref-xq);  % 10% buffer around string
end
if placeToSide
    % Put text to right of, and flush-left to, underflow cursor
    pos(1) = xq-ntx.BarGapCenter;
    horz = 'left';
    xtAdj = +1.5;
    if xq > ntx.RadixPt
        backgr = get(ntx.hHistAxis,'color');
    else
        backgr = 'none';
    end
else
    pos(1) = (xq+ref)/2-ntx.BarGapCenter;
    horz = 'center';
    xtAdj = +0.5;
    backgr = 'none';
end
set(ntx.htFracSpan, ...
    'pos',pos, ...
    'backgr',backgr, ...
    'horiz',horz);
set(ntx.htFracSpan,'units','char');

% fix for y wander bug
pos = get(ntx.htFracSpan,'pos');
pos(1) = pos(1) + xtAdj; % add gutter spacing
pos(2) = psave(2);
set(ntx.htFracSpan,'pos',pos);
