function update_uis(this, varargin)
%UPDATE_UIS  Updates the uis to reflect the current object state

%   Author(s): Z. Mecklai
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.5 $  $Date: 2004/12/26 22:21:55 $

% Determine the current state of the object
opts = get(this, 'AllOptions');
comments = get(this, 'Comment');

handles = get(this, 'handles');
rbs = handles.rbs;

% Turn all the radio buttons off
set(rbs, 'visible', 'off');

% Turn on and set the string for the appropriate number of radio buttons
for indx = 1:length(opts)
    set(rbs(indx), 'visible', this.Visible,...
        'String', opts{indx}, ...
        'Tag', opts{indx});
end

% Update the radio buttons to reflect the current option selection
%allOpts = get(this, 'AllOptions');
allOpts = set(this, 'currentSelection');
currOpt = get(this, 'currentSelection');
currentRb = find(strcmp(allOpts, currOpt));
set(rbs, 'value', 0);
set(rbs(currentRb), 'value', 1);


% Get the handle to the text field.
text = handles.text;

% Set the string into the text field
set(text, 'String', comments);

% Set the position of the text field just below the last 
% visible radio button
setunits(this,'pixels');
set(text, 'position', calculate_positions(this, handles, length(opts)));
setunits(this, 'normalized');

if isempty(comments)
    set(handles.divider, 'visible','off');
    set(handles.text,'visible','off');
else
    set(handles.divider, 'visible',this.Visible);
    set(handles.text,'visible',this.Visible);
end


%-------------------------------------------------------------------------------
function textPos = calculate_positions(this, handles, numrbs)

framePos = get(handles.framewlabel(1), 'Position');
rbsPos   = get(handles.rbs(numrbs)   , 'Position');
divPos   = get(handles.divider       , 'Position');

sz = gui_sizes(this);
sz.indent = 10*sz.pixf;
sz.ufhs = 17*sz.pixf;

textPos = [rbsPos(1),...
        framePos(2) + sz.ufhs,...
        rbsPos(3),...
        rbsPos(2)- framePos(2) - 2*sz.uh];

if isunix, ht = 2;
else,      ht = 1; end

set(handles.divider , 'Position', [rbsPos(1) rbsPos(2) - sz.uuvs rbsPos(3) ht]);


% [EOF]
