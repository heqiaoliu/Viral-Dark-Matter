function updateDTXTextYPos(ntx)
% Update y-coords of all datatype explorer text widgets
% (word length WL, int IL, frac FL, overflow, underflow)
% based on current axis height.
%
% Disregards yWordSpan, and places text relative to top of axis

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:22:01 $

% Get axis extent in char units
hax = ntx.hHistAxis;
set(hax,'units','char');
ax_char = get(hax,'pos');
yTop = ax_char(4);
set(hax,'units','pix');

% Update vertical pos of text readouts
%
ht = [ntx.htWordSpan ntx.htIntSpan ntx.htFracSpan ntx.htOver ntx.htUnder];
set(ht,'units','char');
pos = get(ht,'pos');
pos{1}(2) = yTop-.1;  % offset prevents WL text from touching axis top
pos{2}(2) = yTop-2.1;
pos{3}(2) = yTop-2.1;  % if slope turned on, exponent may hit wordline
pos{4}(2) = yTop-3.5;
pos{5}(2) = yTop-3.5;
set(ht,{'pos'},pos);
