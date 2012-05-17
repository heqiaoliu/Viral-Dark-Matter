function updateXAxisTextPos(ntx)
% Update the text positions of x-axis ticks and labels
% Updates both the x and y positoin of x-axis text.
% No updates to axis limits or label strings are made

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:22:18 $

% Update x-axis tick positions
%
hTicks = ntx.hTicks; % could have more tick labels than needed
xticks = get(ntx.hHistAxis,'xtick'); % numeric tick locations
N = numel(xticks);
for i = 1:N
    % Adjust the y-axis of text labels
    % Setting the top of text to 0% is too close.
    % We need to go to "character" coords to do this right
    ht_i = hTicks(i);
    
    % Update y-pos first
    % This coord can change significantly under unit-conversion
    % Let it go where it needs to go...
    set(ht_i,'units','char');
    pos = get(ht_i,'pos');
    pos(2) = -0.25;  % set y-pos
    set(ht_i,'pos',pos);
    
    % Update x-pos
    % This coord must be rock-solid so labels line up with ticks
    set(ht_i,'units','data')
    pos = get(ht_i,'pos');
    pos(1) = xticks(i); % set x-pos
    set(ht_i,'pos',pos);
    
    % Leave tick labels in pixel units, so labels don't move
    % during y-axis changes, etc
    set(ht_i,'units','pix');
end

% Update x-axis title position
%  - center on x-axis data limits
%  - place one char below x-tick labels
hXLabel = ntx.htXLabel;
set(hXLabel,'units','data');
pos = get(hXLabel,'pos');
xlim = get(ntx.hHistAxis,'xlim');
pos(1) = sum(xlim)/2;
set(hXLabel,'pos',pos);

% Set y-pos of label in char units
set(hXLabel,'units','char');
pos = get(hXLabel,'pos');
pos(2) = -1.75; % chars below axis ticks, leaving room for superscript
set(hXLabel,'vert','top','pos',pos);

% Restore back to pixels
set(hXLabel,'units','pix');
