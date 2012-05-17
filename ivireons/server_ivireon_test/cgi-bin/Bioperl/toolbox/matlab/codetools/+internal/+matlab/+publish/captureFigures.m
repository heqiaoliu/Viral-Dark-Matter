function oldFigures = captureFigures(oldHandles)
%CAPTUREFIGURES	Return figure information for later call to compareFigures
%   OLDFIGURES contains the information that can later be passed to
%   the compareFigures function

% Copyright 1984-2008 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2009/09/03 05:18:44 $

% The publishing tools and Notebook uses this.

% Call drawnow here to flush any changes/events that may have been
% triggered if the last loop of takepicture triggered a print.
% This drawnow could be taken out if the print of a uiflowcontainer does
% not trigger a resize (G354913).  It takes two.
drawnow;
drawnow;

% A structure representing the graphics hierarchy, starting with figures.
if nargin == 0
    oldHandles = flipud(allchild(0));
end
numHandles = numel(oldHandles);
oldFigures.data = handle2struct([]);

% Recursively visit each node, modifying or removing it where appropriate.
toRemove = false(1, numHandles);
for k = 1:numHandles
    oldFigures.data(k) = handle2struct(oldHandles(k));
    [oldFigures.data(k), toRemove(k)] = visit(oldFigures.data(k));
end
oldFigures.data(toRemove) = [];

% Since HANDLE2STRUCT([]) returns an empty structure of the appropriate
% form, we don't need to worry about compareFigures seeing differences
% between different kinds of empty structures.  (See below, in VISIT.)

% The "id" for graphics objects is the handle.
oldFigures.id = [oldFigures.data.handle];

end

% The aim of VISIT is to produce a structure of the appropriate form for
% compareFigures, including only information that could visibly affect the
% figure, so that when compared, snaps occur at the appropriate times.
%
% It makes use of the following definitions:
%
% ISHIDDEN is true if the object in question, and its children, make no
% visible contribution to the space available to it in its parent.  That 
% is, if ISHIDDEN is true, one "sees through" the object to the parent.
%
% ISNOTVISIBLE is true or false according to whether the object's 'Visible'
% property is 'off' or 'on', respectively.
%
% Under most circumstances the following is true:
%
% A:  ISNOTVISIBLE =>  ISHIDDEN
% B: ~ISNOTVISIBLE => ~ISHIDDEN     
% C:      ISHIDDEN =>  Remove item from list of children
% D:     ~ISHIDDEN =>  Do not remove item from list of children     
%
% Exceptions:
%
% A: An axes with 'Visible' set to 'off' and some child showing.
%    That is, you can see lines and things in the axes, even if you don't
%    see the tick marks, etc.
%
% B: A text object with 'Visible' set to 'on' and 'String' set to ''.
% B: Or an hggroup object with no visible children.
%    Both of these are visually undetectable.
%
% C: A hidden axes contained in an (undocumented) uiflowcontainer.
% C: A hidden axes contained in an (undocumented) uigridcontainer.
%    It is not seen, but its presence affects the location of its siblings.
%    It needs to be replaced with a placeholder in the "children" list.
%
% D: No exceptions.  However, the parent may be removed from its parent's
%    list, if appropriate.

function [node, thisIsHidden] = visit(node)
% [NODE, ISHIDDEN] = visit(NODE) recursively visits the "children" of NODE,
% and returns a modified version of NODE.  
%
% ISHIDDEN is a flag indicates that the caller should remove the node from
% the "children" list, unless it is needed as a placeholder.  In this case,
% the caller must replace the node with an appropriate placeholder.

% For convenience and efficiency:
typeMatch = strcmp(node.type, {'figure' ...
                               'axes' ...
                               'text' ...
                               'uicontextmenu' ...
                               'hggroup' ...
                               'scribe.legend' ...
                               'scribe.scribeaxes'});
                           
isFigure          = typeMatch(1);
isAxes            = typeMatch(2) || typeMatch(6) || typeMatch(7);
isText            = typeMatch(3);
isUicontextmenu   = typeMatch(4);
isHggroup         = typeMatch(5);

% Determine the "Visible" property of the object: It is not in the struct
% if it is the default. Uicontextmenu's default is "off", others are "on".
if isfield(node.properties, 'Visible')
    thisIsNotVisible = strcmp(node.properties.Visible, 'off');
else
    thisIsNotVisible = isUicontextmenu;
end

% Exit early if we can determine (here) that this node is hidden.
if definitelyHidden
    thisIsHidden = true;
    return;
end

% Make appropriate property adjustments to prevent extra figure snaps.
adjustProperties;

% Visit each child node, building a vector of their ISHIDDEN outputs.
childIsHidden = false(size(node.children));
for k = 1:numel(node.children)
    [node.children(k), childIsHidden(k)] = visit(node.children(k));
end

% Prune the hidden children from the tree.
% This also sets the final status of "thisIsHidden".
thisIsHidden = removeHiddenChildren;

    function thisIsHidden = removeHiddenChildren
        
        if all(childIsHidden(:))
            % It no children or they are all marked for removal.
            
            if thisIsNotVisible || isHggroup
                thisIsHidden = true;
                
                % No need to remove the children, as this node will be
                % removed or replaced in the parent's list of children.
            else
                thisIsHidden = false;
                
                % Provide a standard "empty" list of children (see Note).
                node.children = [];
            end
        else
            % It has some children showing.  The call to definitelyHidden
            % ensures that all objects here have 'Visible' set to 'on', 
            % with the exception of axes and scribe.legend objects, where
            % it doesn't matter because the children "show through".            
            thisIsHidden = false;
            
            % Remove the selected children.
            node.children(childIsHidden) = [];
            
            % In theory, any hidden axes objects in the children list of a
            % uiflowcontainer or uigridcontainer should be replaced with a
            % placeholder containing only the WidthLimits and HeightLimits
            % properties (istead of being removed), because the object does
            % affect the position of its siblings.  This is omitted because
            % it requires children to report not only whether they are
            % hidden, but also their type.  
        end
        
        % Note:
        %
        %    node.children(childIsHidden) = [];
        %
        % cannot be used to remove all the children, as it will result in
        % either an empty double or an empty struct, depending on whether
        % node.children was empty to begin with. This would trip up
        % compareFigures, since ISEQUALWITHEQUALNANS sees them as
        % different.  This is why as "standard empty list" is used.          
    end

    function adjustProperties
        % Changes to application data can be discarded. The same holds for
        % changes to various other things (UserData, Callback properties,
        % etc.), but for efficiency, these are not cleared.
        node.properties.ApplicationData = [];        

        if isFigure
            % The windowing system can move a figure after it is
            % created, so ignore the position of the figure on the
            % screen.  The figure dimensions are also not reliable.
            % See g197164.
            node.properties.Position = [];

            % Some unknown callback could change the CurrentAxes
            % But that shouldn't be captured in the structure.
            % See g273048.
        elseif isAxes
            % The "special" field captures indices to text children which
            % form the title, xlabel, ylabel, zlabel.  We can discard this
            % information because we will remove any empty text objects.
            node.special = [];   
            
            % This field is also used by the uicontextmenu, to capture the
            % list of objects who use it as their context menu.  This is
            % would cause an extra snap only if it was changed as the list
            % was visible.
        end
    end

    function flag = definitelyHidden
        if isAxes
            % Axes may have children that show, even when invisible.
            flag = false;
        elseif thisIsNotVisible
            % Other objects don't show if they are invisible.
            flag = true;    
        elseif isText
            % Even when 'Visible' is 'on', a text object does not show if
            % it has an empty string (the default).
            flag =   ~isfield(node.properties, 'String') ...
                   || isempty(node.properties.String);
            
            % This is important because a GET on an axes or scribe.legend
            % will create four string-less text objects to serve as labels.
            % If they are not removed, an extra snap will happen.            
        else
            % These are definitely not hidden.
            flag = false;    
        end
    end

end
