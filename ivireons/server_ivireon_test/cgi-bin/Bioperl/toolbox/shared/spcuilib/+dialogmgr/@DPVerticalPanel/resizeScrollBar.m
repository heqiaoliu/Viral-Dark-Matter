function resizeScrollBar(dp)
% Make scroll bar visible and reposition it if ScrollFraction < 1.
% Install new "active bar" height.
%
% Requires:
% - hParent position to be updated (done via resizeParentPanel())
% - ScrollFraction to be updated (done via updateDialogPositions())
%
% What we really need is to recalculate the display fraction now,
% for a potentially new set of dialog parameters, before proceeding
% This is done in updateDialogPositions(), which is called by
% resizeChildPanels()

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:40:16 $

frac = dp.ScrollFraction;
if ~dp.PanelVisible || frac>=1
    set(dp.hScrollBar,'vis','off');
else
    % Calculate new position for the scroll bar,
    % and make it visible
    
    % Get size of Parent panel
    ppos = get(dp.hParent,'pos');
    parentWidth  = ppos(3);
    parentHeight = ppos(4);
    
    % Get main info panel specs
    gutterFig  = dp.GutterInfoFig; % gutter between infopanel and figure edge
    
    % We can grab ScrollWidth directly here, and not via getScrollWidth(),
    % since we've already done visible and frac checks above
    scrollWidth = dp.ScrollWidth;
    
    infoPanelOnLeft = strcmpi(dp.DockLocation,'left');
    if infoPanelOnLeft
        % [<------------------------- parentWidth ------------------------>]
        % 1                                                                N
        % [gutterFig][scroll][gutterScroll][dlgPanel][gutterBody][bodyPanel]
        %        x0->|
        scroll_x0 = gutterFig+1; % x origin
        
    else % info panel on right
        % [<------------------ parentWidth ------------------------------->]
        % 1                                                                N
        % [bodyPanel][gutterBody][dlgPanel][gutterScroll][scroll][gutterFig]
        %                                            x0->|
        scroll_x0 = max(1,parentWidth-gutterFig-scrollWidth+1);
    end
    
    % Calculate height of "active bar" within scroll
    minStepSize = 0.05; % 20 steps using arrows
    maxStepSize = dialogmgr.maxStepSizeForLinearSliderLength(frac);

    % xxx this is a bug workaround for using maxStepSize>1
    %   - when maxStepSize>1, and the maxStepSize is then reduced to <1,
    %     the Value property gets ignored and the active bar moves to the
    %     bottom of the scroll.  We cannot simply reset the current value,
    %     since HG identifies this as the same value as optimizes the call
    %     by ignoring the change.  We want HG to see a change in value so
    %     it re-renders the active bar, and doing so in the right position,
    %     fixing the bug.  To do this, we set a different value, then set
    %     it back.
    %
    % Reinstall the "active bar" vertical position within scroll.
    % Nudge it by 0.1% (too small to notice visually, but large enough for
    % HG to force re-render of the widget)
    sliderBarValue = get(dp.hScrollBar,'Value');
    set(dp.hScrollBar, ...
        'SliderStep',[minStepSize maxStepSize], ...
        'Value',sliderBarValue*1.001, ...
        'pos',[scroll_x0, 1, scrollWidth, parentHeight], ...
        'vis','on');
    set(dp.hScrollBar,'Value',sliderBarValue);
end

