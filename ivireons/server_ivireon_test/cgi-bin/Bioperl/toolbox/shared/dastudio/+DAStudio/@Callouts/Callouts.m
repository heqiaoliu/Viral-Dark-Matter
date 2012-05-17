classdef Callouts < handle

    % Copyright 2007 The Mathworks, Inc

    properties
        % Arrow properties 
        ArrowColor = [0.5 0.5 0.5 1]; %gray

        % First element is the distance from the neck to the tip.
        % Second element is the distance from the trailing point to the tip.
        % Third element is the distance from the line to the outside edge. 
        ArrowShape = [8 10 3];

        ArrowStrokeWidth = 1;

        % Label properties
        FontAngle   = 'NORMAL_ANGLE';
        FontColor   = [0 0.3 0 1]; % light green
        FontName    = 'Helvetica';
        FontSize    = 12;
        FontWeight  = 'BOLD_WEIGHT';

        % Circle properties
        CircleColor = [0 0 0 1]; %black
        CircleSpace = 5;
        CircleStrokeWidth = 1;

        Portal = [];
        
        % Callout rectangle
        CalloutRect = []; %[x1 y1 w h]
        minSpace = 5;
    end

    properties (Dependent = true)
        Canvas;
%         Layer;
        GLRCModel;
    end
    
    properties (GetAccess = 'private', SetAccess = 'private')
        Occupied = [];
        isRoomLeft = true;
    end

    methods
        function disp(this)
            disp(sprintf([...
                '[%s]\n', ...
                '         ArrowColor: %s\n', ...
                '         ArrowShape: %s\n', ...
                '   ArrowStrokeWidth: %d\n', ...
                '          FontAngle: ''%s''\n', ...
                '          FontColor: %s\n', ...
                '           FontName: ''%s''\n', ...
                '           FontSize: %d\n', ...
                '         FontWeight: ''%s''\n', ...
                '        CircleColor: %s\n', ...
                '        CircleSpace: %d\n', ...
                '  CircleStrokeWidth: %d\n', ...
                '        CalloutRect: %s\n'], ...
                class(this), ...
                this.getVectStr(this.ArrowColor), ...
                this.getVectStr(this.ArrowShape), ...
                this.ArrowStrokeWidth, ...
                this.FontAngle, ...
                this.getVectStr(this.FontColor), ...
                this.FontName, ...
                this.FontSize, ...
                this.FontWeight, ...
                this.getVectStr(this.CircleColor), ...
                this.CircleSpace, ...
                this.CircleStrokeWidth, ...
                this.getVectStr(this.CalloutRect)));
        end

        function canvas = get.Canvas(this)
            canvas = this.Portal.getCanvas();
        end

        %         function layer = get.Layer(this)
        %             layers = this.Canvas.getLayers();
        %             layer = layers(2);
        %         end
        %

        function this = set.Portal(this, newPortal)
            if isa(newPortal, 'Portal.Portal')
                this.Portal = newPortal;
                this.isRoomLeft = true;
                this.Occupied = [];
            else
                error('DAStudio:Callouts:InvalidPortal', 'Invalid Portal');
            end
        end

        function glrcModel = get.GLRCModel(this)
            canvas = this.Canvas;
            layers = canvas.getLayers();
            layer = layers(2);
            glrcModel = layer.getModel();
        end

        function this = Callouts(varargin)
            for i = 1:2:nargin
                this.(varargin{i}) = varargin{i+1};
            end
        end

        function location = addAutoCallout(this, label, trgRect)
            assert(~isempty(this.CalloutRect), ...
                'DAStudio:Callouts:CalloutRect', 'CalloutRect not specified!');

            % target's middle sides
            trg.top    = [(trgRect(1)+trgRect(3)/2), trgRect(2)];
            trg.left   = [trgRect(1),                (trgRect(2)+trgRect(4)/2)];
            trg.bottom = [(trgRect(1)+trgRect(3)/2), (trgRect(2)+trgRect(4))];
            trg.right  = [(trgRect(1)+trgRect(3)),   (trgRect(2)+trgRect(4)/2)];

            % best location on each side of the callout rect
            cRect = this.CalloutRect;
            bestLabel.top    = [trg.top(1),          cRect(2)];
            bestLabel.left   = [cRect(1),            trg.left(2)];
            bestLabel.bottom = [trg.bottom(1),       (cRect(2)+cRect(4))];
            bestLabel.right  = [(cRect(1)+cRect(3)), trg.right(2)];

            % find the best possible label point
            [labelPoint arrowPoint] = this.findMinDistance( ...
                [bestLabel.left; bestLabel.bottom; bestLabel.right; bestLabel.top], ...
                [trg.left;       trg.bottom;       trg.right;       trg.top]);

            % create callout
            if this.isRoomLeft
                [calloutNode, location] = this.createCallout(label, labelPoint, arrowPoint);

                if this.isOccupied(location)
                    % callout already occupies best location, find next best location
                    [cLabelPoint, cArrowPoint] = this.getNextPoint(1, ...   % clockwise
                        labelPoint, location(3), trg);
                    if ~isempty(cLabelPoint)
                        [ccLabelPoint, ccArrowPoint] = this.getNextPoint(-1, ... % counter-clockwise
                            labelPoint, location(3), trg);
                    end

                    if ~isempty(cLabelPoint) && ~isempty(ccLabelPoint)
                        % pick the closest, clock-wise or counter-clock-wise
                        [labelPoint arrowPoint] = this.findMinDistance( ...
                            [cLabelPoint; ccLabelPoint], ...
                            [cArrowPoint; ccArrowPoint]);

                        % move it
                        this.moveCallout(calloutNode, labelPoint, arrowPoint);

                    else
                        % no space left!
                        this.isRoomLeft = false;
                        this.removeNode(calloutNode);
                    end

                end
            end

            % callouts are label.  return [cx xy r] for use in image maps
            if this.isRoomLeft
                location = [labelPoint location(3)];
                this.addOccupied(location);
            else
                location = [];
            end
        end

        function removeNode(this, nodes) 
            m = this.GLRCModel;
            for node = nodes(:)'
                m.removeNode(node);
            end
        end            
            
        function [calloutNode, location] = createCallout(this, label, labelPoint, arrowPoint)
            % label       Callout text
            % labelPoint  Center of callout text [x y]
            % arrowPoint  Tip of arrow [x y]
  
            %%%% Draw Label %%%%
            labelNode = createLabel(this, label, labelPoint);
            layers = this.Canvas.getLayers();
            labelBounds = layers(2).getDrawState(labelNode).bounds;

            %%%% Draw Circle %%%%
            if labelBounds(3) > labelBounds(4)
                radius = labelBounds(3)/2 + this.CircleSpace + this.CircleStrokeWidth/2;
            else
                radius = labelBounds(4)/2 + this.CircleSpace + this.CircleStrokeWidth/2;
            end
            circleNode = createCircle(this, labelPoint, radius);

            %%%% Arrow Line %%%%
            % Determine where arrow starts from the circle
            vecLength = this.getDistance(labelPoint, arrowPoint);
            arrowStart = labelPoint + ...
                (radius / vecLength) * (arrowPoint - labelPoint);
            arrowNode = createArrow(this, arrowStart, arrowPoint);
            
            calloutNode = [labelNode circleNode, arrowNode];
            location = [labelPoint, radius];
        end
        
        function moveCallout(this, calloutNode, newLabelPoint, newArrowPoint)
            % calloutNode    Array of GLRC container nodes for text, circle
            %                and arrow.
            % newLabelPoint  New center of callout text [x y]
            % newArrowPoint  New tip of arrow [x y] (optional)
    
            labelNode = calloutNode(1);
            circleNode = calloutNode(2);
            arrowNode = calloutNode(3);

            if (nargin < 4)
                newArrowPoint = this.getArrowEndPoint(arrowNode);
            end

            this.moveLabel(labelNode, newLabelPoint);
            this.moveCircle(circleNode, newLabelPoint);

            % Get arrow start point on the circle
            glrcCircleNode = find(circleNode.getChildren, ...
                '-isa', 'DAStudio.GLRCEllipseNodeRef');
            radius = glrcCircleNode.width/2;
            vecLength = this.getDistance(newLabelPoint, newArrowPoint);
            newArrowStart = newLabelPoint + ...
                (radius / vecLength) * (newArrowPoint - newLabelPoint);
    
            this.moveArrow(arrowNode, newArrowStart, newArrowPoint)
        end
        
        function labelNode = createLabel(this, label, labelPoint)
            % label       Text label
            % labelPoint  Label center point
            
            % Text properties
            textFormat  = 'SIMPLE_FORMAT';
            hAlign      = 'LEFT_TEXT';
            vAlign      = 'BASELINE_TEXT';
            % Center is not really center!, use bottom left and adjust
            %hAlign      = 'H_CENTER_TEXT'; 
            %vAlign      = 'V_CENTER_TEXT';

            % Add a separator to hold text node draw properties
            m = this.GLRCModel;
            labelNode = m.createSeparatorNode();
            m.addNode(labelNode);

            % Draw it!
            m.addNode(labelNode, m.createStrokeNode(this.FontColor));
            m.addNode(labelNode, m.createFontNode(this.FontName, ...
                                                  this.FontSize, ...
                                                  this.FontWeight, ...
                                                  this.FontAngle));
            txtNode =  m.createTextNode(labelPoint(1), ...
                                        labelPoint(2), ...
                                        label, ...
                                        hAlign, ...
                                        vAlign, ...
                                        textFormat);
            m.addNode(labelNode, txtNode);

            % Fix txt node position to be center
            this.center(txtNode);
        end
        
        function moveLabel(this, labelNode, newPoint)
            % labelNode   GLRC container node
            % newPoint    New label center point  [x y]

            glrcLabelNode = find(labelNode.getChildren, ...
                '-isa', 'DAStudio.GLRCTextNodeRef');

            if ~isempty(glrcLabelNode)
                glrcLabelNode.x = newPoint(1);
                glrcLabelNode.y = newPoint(2);
                this.center(glrcLabelNode);
            end
        end
        
        function circleNode = createCircle(this, centerPoint, radius)
            % centerPoint   Circle center [x y]
            % radius        Circle radius

            % Determine top left corner
            topLeft = centerPoint - radius;

            % Add a separator to hold circle node draw properties
            m = this.GLRCModel;
            circleNode = m.createSeparatorNode();
            m.addNode(circleNode);

            % Draw it!
            diameter = 2*radius;
            m.addNode(circleNode, m.createStrokeNode(this.CircleColor));
            m.addNode(circleNode, m.createStrokeWidthNode(this.CircleStrokeWidth));
            m.addNode(circleNode, m.createEllipseNode(topLeft(1), ...
                                                      topLeft(2), ...
                                                      diameter, ...
                                                      diameter));
        end
        
        function moveCircle(this, circleNode, newPoint) %#ok
            % labelNode   GLRC container node
            % newPoint    New circle center point [x y]

            glrcCircleNode = find(circleNode.getChildren, ...
                '-isa', 'DAStudio.GLRCEllipseNodeRef');
            radius = glrcCircleNode.width/2;
            if ~isempty(glrcCircleNode)
                glrcCircleNode.x = newPoint(1) - radius;
                glrcCircleNode.y = newPoint(2) - radius;
            end
        end

        function arrowNode = createArrow(this, startPoint, endPoint)
            % startPoint     Start of line [x y]
            % endPoint       End of line, arrow tip, [x y]

            % Determine points to draw the arrow head
            [arrowHeadNode, basePoint] = this.createArrowHead(startPoint, ...
                                                              endPoint);

            % Add a separator to hold draw properties
            m = this.GLRCModel;
            arrowNode = m.createSeparatorNode();
            m.addNode(arrowNode);

            % Draw it!
            m.addNode(arrowNode, m.createStrokeNode(this.ArrowColor));
            m.addNode(arrowNode, m.createStrokeWidthNode(this.ArrowStrokeWidth));
            m.addNode(arrowNode, m.createLineNode(startPoint(1), ...
                                                  startPoint(2), ...
                                                  basePoint(1), ...
                                                  basePoint(2)));
            %m.addNode(arrowNode, m.createFillNode(this.ArrowColor));
            m.addNode(arrowNode, m.createStrokeWidthNode(1));
            m.addNode(arrowNode, m.createPathNode(arrowHeadNode));
        end

        function moveArrow(this, arrowNode, newStartPoint, newEndPoint)
            % arrowNode         GLRC container node
            % newStartPoint     Start of line [x y]
            % newEndPoint       End of line, arrow tip, [x y] (optional)
         
            glrcPathNode = find(arrowNode.getChildren, ...
                '-isa', 'DAStudio.GLRCPathNodeRef');
            glrcLineNode = find(arrowNode.getChildren, ...
                '-isa', 'DAStudio.GLRCLineNodeRef');
            
            if (nargin < 4)
                % keep original endpont
                newEndPoint = this.getArrowEndPoint(arrowNode);
            end

            % Create new arrow head
            [newArrowHeadNode, newBasePoint] = createArrowHead( ...
                this, newStartPoint, newEndPoint);
            
            % Move Line
            glrcLineNode.x1 = newStartPoint(1);
            glrcLineNode.y1 = newStartPoint(2);            
            glrcLineNode.x2 = newBasePoint(1);
            glrcLineNode.y2 = newBasePoint(2);

            % Reorient arrow
            glrcPathNode.path = newArrowHeadNode;
        end
        
        function rectNode = createRectangle(this, rect)
            % rect     Rectangle [x y w h]

            % Add a separator to hold rectangle node draw properties
            m = this.GLRCModel;
            rectNode = m.createSeparatorNode();
            m.addNode(rectNode);

            % Draw it!
            m.addNode(rectNode, m.createRectNode(rect(1), rect(2), rect(3), rect(4)));
        end
        
        function moveRectangle(this, rectNode, newPoint) %#ok
            % rectNode       GLRC container node
            % newPoint       New top left corner [x y]

            glrcRectNode = find(rectNode.getChildren, ...
                '-isa', 'DAStudio.GLRCRectNodeRef');
            if ~isempty(glrcRectNode)
                glrcRectNode.x = newPoint(1);
                glrcRectNode.y = newPoint(2);
            end
        end
    end
    
    methods (Access = 'private')
        function vectStr = getVectStr(this, vect) %#ok
            vectStr = '[';
            if ~isempty(vect)
                vectStr = [vectStr sprintf('%.2f', vect(1)) ];
            end
            for i = 2:length(vect)
                vectStr = [vectStr ' ' sprintf('%.2f', vect(i)) ]; %#ok
            end

            vectStr = [vectStr ']'];
        end

        function center(this, node)
            layers = this.Canvas.getLayers();
            bounds = layers(2).getDrawState(node).bounds;
            node.x = node.x - bounds(3)/2;
            node.y = node.y + bounds(4)/2 - 1;
        end

        function dist = getDistance(this, point1, point2) %#ok
            dist = sqrt( sum((point1 - point2).^2) );
        end

        function [minPoint1, minPoint2] = findMinDistance(this, point1, point2)
            assert(length(point1) == length(point2));
            minPoint1 = point1(1,:);
            minPoint2 = point2(1,:);
            minDist = this.getDistance(minPoint1, minPoint2);
            for i = 2:length(point1)
                dist = this.getDistance(point1(i,:), point2(i,:));
                if (minDist > dist)
                    minDist = dist;
                    minPoint1 = point1(i,:);
                    minPoint2 = point2(i,:);
                end
            end
        end

        function [arrowHeadNode, neckPoint] = createArrowHead(this, startPoint, endPoint)
            vec = startPoint - endPoint;
            vec = vec / sqrt(vec * vec');
            perpVec = [vec(2), -vec(1)];
            
            basePoint = endPoint + vec*this.ArrowShape(2);
            neckPoint = endPoint + vec*this.ArrowShape(1);
            point1 = basePoint - perpVec*this.ArrowShape(3);
            point2 = basePoint + perpVec*this.ArrowShape(3);

            arrowHeadNode = DAStudio.GLRCPath( ...
                [endPoint(1) point1(1) neckPoint(1) point2(1) endPoint(1)], ...
                [endPoint(2) point1(2) neckPoint(2) point2(2) endPoint(2)], 5);
        end
        
        function arrowEndPoint = getArrowEndPoint(this, arrowNode) %#ok
            glrcPathNode = find(arrowNode.getChildren, ...
                '-isa', 'DAStudio.GLRCPathNodeRef');
            pathPoints = glrcPathNode.path.getPoints;
            arrowEndPoint = pathPoints(1,:);
        end
       
        function addOccupied(this, newCircle)
            this.Occupied = [this.Occupied; newCircle];
        end

        function tf = isOccupied(this, circle)
%             % Faster to use rects

%             tf = false;
%             i = 1;
%             nOccupied = size(this.Occupied, 1);
%             while (~tf && (i <= nOccupied))
%                 dist = this.getDistance(circle(1:2), this.Occupied(i, 1:2));
%                 if (dist < (circle(3) + this.Occupied(i, 3) + this.minSpace))
%                     tf = true;
%                 end
%                 i = i + 1;
%             end

            left1   = circle(1) - circle(3) - this.minSpace;
            top1    = circle(2) - circle(3) - this.minSpace;
            right1  = left1 + 2*(circle(3) + this.minSpace);
            bottom1 = top1 + 2*(circle(3) + this.minSpace);
            
            tf = false;
            i = 1;
            nOccupied = size(this.Occupied, 1);
            while (~tf && (i <= nOccupied))
                
                circle2 = this.Occupied(i,:);
                left2   = circle2(1) - circle2(3);
                top2    = circle2(2) - circle2(3);
                right2  = left2 + 2*circle2(3);
                bottom2 = top2 + 2*circle2(3);
            
                tf = true;
                if (top1 > bottom2 || top2 > bottom1)
                    tf = false;
                else
                    if (right1 < left2 || right2 < left1)
                        tf = false;
                    end
                end
                
                i = i + 1;
            end

        end
        
        function [labelPoint, arrowPoint] = getNextPoint(this, direction, startPoint, radius, trg)
        
            cRect = this.CalloutRect;
            increment = direction*radius/2;
            labelPoint = startPoint;
            changeSide = 0;
            
            while this.isOccupied([labelPoint radius]) && (changeSide < 4)
                if this.isCalloutRectLeft(labelPoint)
                    labelPoint = [labelPoint(1), labelPoint(2) - increment];
                    arrowPoint = trg.left;
                    if ~this.isCalloutRectLeft(labelPoint)
                        if direction == 1
                            arrowPoint = trg.top;
                            labelPoint = [cRect(1) + 1, cRect(2)];
                        else
                            arrowPoint = trg.bottom;
                            labelPoint = [cRect(1) + 1, cRect(2) + cRect(4)];
                        end
                        changeSide = changeSide + 1;
                    end

                elseif this.isCalloutRectTop(labelPoint)
                    labelPoint = [labelPoint(1) + increment, labelPoint(2)];
                    arrowPoint = trg.top;
                    if ~this.isCalloutRectTop(labelPoint)
                        if direction == 1
                            arrowPoint = trg.right;
                            labelPoint = [cRect(1) + cRect(3), cRect(2)];
                        else
                            arrowPoint = trg.left;
                            labelPoint = [cRect(1), cRect(2)];
                        end
                        changeSide = changeSide + 1;
                    end
                    
                elseif this.isCalloutRectRight(labelPoint)
                    arrowPoint = trg.right;
                    labelPoint = [labelPoint(1), labelPoint(2) + increment];
                    if ~this.isCalloutRectRight(labelPoint)
                        if direction == 1
                            arrowPoint = trg.bottom;
                            labelPoint = [cRect(1) + cRect(3) - 1, cRect(2) + cRect(4)];
                        else
                            arrowPoint = trg.top;
                            labelPoint = [cRect(1) + cRect(3) - 1, cRect(2)];
                        end
                        changeSide = changeSide + 1;
                    end
                        
                elseif this.isCalloutRectBottom(labelPoint)
                    arrowPoint = trg.bottom;
                    labelPoint = [labelPoint(1) - increment, labelPoint(2)];
                    if ~this.isCalloutRectBottom(labelPoint)
                        if direction == 1
                            arrowPoint = trg.left;
                            labelPoint = [cRect(1), cRect(2) + cRect(4)];
                        else
                            arrowPoint = trg.right;
                            labelPoint = [cRect(1) + cRect(3), cRect(2) + cRect(4)];
                        end
                        changeSide = changeSide + 1;
                    end
                        
                else
                    warning('DAStudio:Callouts:CalloutRect', 'Unexpected next callout point!');
                    break
                end
            end
            
            if (changeSide == 4)
                arrowPoint = [];
                labelPoint = [];
                warning('DAStudio:Callouts:CalloutRect', 'No room left for callouts!');
            end
        end
        
        function tf = isCalloutRectLeft(this, point)
            cRect = this.CalloutRect;
            tf = (point(1) == cRect(1)) ...             % same x distance
                && (point(2) >= cRect(2)) ...           % greater than top side
                && (point(2) <= (cRect(2) + cRect(4))); % smaller than bottom side
        end

        function tf = isCalloutRectTop(this, point)
            cRect = this.CalloutRect;
            tf = (point(2) == cRect(2)) ...            % same y distance
                && (point(1) > cRect(1)) ...           % greater than left side
                && (point(1) < (cRect(1) + cRect(3))); % smaller than right side
        end

        function tf = isCalloutRectRight(this, point)
            cRect = this.CalloutRect;
            tf = (point(1) == (cRect(1) + cRect(3))) ...  % same x distance
                && (point(2) >= cRect(2)) ...             % greater than top side
                && (point(2) <= (cRect(2) + cRect(4)));   % smaller than bottom side
        end

        function tf = isCalloutRectBottom(this, point)
            cRect = this.CalloutRect;
            tf = (point(2) == (cRect(2) + cRect(4))) ... % same y distance?
                && (point(1) > cRect(1)) ...             % greater than left side   
                && (point(1) < (cRect(1) + cRect(3)));   % smaller than right side
        end
    end
end

