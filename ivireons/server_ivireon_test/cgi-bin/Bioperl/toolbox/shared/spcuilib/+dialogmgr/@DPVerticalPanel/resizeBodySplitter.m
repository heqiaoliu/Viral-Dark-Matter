function resizeBodySplitter(dp)
% Reposition dialog body splitter bar.
%
% Renders within gutter between Body and Dialog panels

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:40:13 $

% Get size of Parent panel (size is independent of reference frame)
hParent = dp.hParent;
ppos = get(hParent,'pos');
parentWidth  = ppos(3);
parentHeight = ppos(4);

% Get main info panel specs
infoWidth    = dp.PanelWidth; % total width of main panel, in pixels
gutterFig    = dp.GutterInfoFig; % gutter between infopanel and figure edge
gutterBody   = dp.GutterInfoBody;
gutterScroll = dp.ScrollGutter;
scrollWidth  = getScrollWidth(dp);

if ~dp.PanelVisible
    % DialogPanel not visible
    % Reset infoWidth so splitter code below knows what to do
    infoWidth = 0;
    gutterFig = 0; % leave gutterBody, it's where the AutoHideBar renders
end

infoPanelOnLeft = strcmpi(dp.DockLocation,'left');
if infoPanelOnLeft
    % [<------------------------- parentWidth ------------------------>]
    % 1                                                                N
    % [gutterFig][scroll][gutterScroll][dlgPanel][gutterBody][bodyPanel]
    %                                        x0->|
    gutterBody_x0 = gutterFig+scrollWidth+gutterScroll+infoWidth+2; % x origin
    
else % info panel on right
    % [<------------------------- parentWidth ------------------------>]
    % 1                                                                N
    % [bodyPanel][gutterBody][dlgPanel][gutterScroll][scroll][gutterFig]
    %        x0->|
    gutterBody_x0 = max(1, ...
        parentWidth-gutterFig-scrollWidth-gutterScroll-infoWidth-gutterBody+1);
end
% Center the splitter within gutterBody itself
splitterSize = getSize(dp.hBodySplitter);
splitter_x0 = gutterBody_x0 + floor((gutterBody - splitterSize(1))/2);
splitter_y0 = floor((parentHeight-splitterSize(2))/2);
dp.hBodySplitter.Location = [splitter_x0, splitter_y0];


