function renderToPortal(this)

    % Copyright 2007 The Mathworks, Inc

    % Make sure portal is set
    if isempty(this.Source)
        error('DAStudio:Snapshot:NoSource', 'Source is not set!');
    end
    
    % Get portal
    portal = this.Portal;

    % Reset target
    portal.targetObject = [];
    portal.targetObject = this.Source;

    % Initialize runtime variables
    this.initRuntimeVariables();

    % Set view
    vB = this.RuntimeViewExtents.viewBox;
    portal.viewExtents.clear;
    portal.viewExtents.unionPt(Portal.Point(vB(1), vB(2)));
    portal.viewExtents.unionPt(Portal.Point(vB(1)+vB(3), ...
                                            vB(2)+vB(4)));

    % Adjust for Stateflow background rendering
    if isa(this.Source, 'Stateflow.Object')
        locFixStateflowBackground(this.Portal)
    end

    % Set portal to runtime size
    imgSize = this.RuntimeSize;
    this.Portal.size = Portal.Point(imgSize(1), imgSize(2));

    % Set margins
    margins = this.RuntimeMargins;
    portal.minimumMargins.clear;
    portal.minimumMargins.top    = margins.top;
    portal.minimumMargins.left   = margins.left;
    portal.minimumMargins.bottom = margins.bottom;
    portal.minimumMargins.right  = margins.right;

    % Render frame
    if this.AddFrame
        frameObj = DAStudio.Frame;
        frameObj.FrameFile = this.FrameFile;
        frameObj.render(portal, margins);
    end

    % Get scale and offset (used by convertToPortalPosition method)
    canvas = portal.getCanvas();
    layers = canvas.getLayers();
    this.RuntimeOffset = layers(1).offset;
    this.RuntimeScale = layers(1).scale(1);
    
    % Render callouts
    calloutList = this.RuntimeCalloutList;
    if ~isempty(calloutList)
        calloutSpace = this.convertToPixels(this.CalloutSpace, this.Units);
        this.RuntimeCalloutPointers = locRenderCallouts(this, ...
            portal, ...
            imgSize, ...
            margins, ...
            calloutSpace, ...
            calloutList);
    end
    
    % Set Orientation
    orientation = this.RuntimeOrientation;
    this.RuntimeRotation = locSetOrientation(portal, orientation);
    if ~strncmpi(orientation, 'p', 1)
        this.RuntimeSize = fliplr(this.RuntimeSize);
    end

end

%-------------------------------------------------------------------------------
function rotated = locSetOrientation(portal, orientation)
    % Set portal orientation

    switch lower(orientation)
        case 'portrait'
            rotated = 0;
        case 'landscape'
            rotated = pi/2;
        case 'rotated'
            rotated = 3/2 * pi;
        otherwise
            error('DAStudio:Snapshot:UnexpectedOrientation', ...
                'Unexpected orientation %s.', orientation);
    end

    canvas = portal.getCanvas();
    layers = canvas.getLayers();

    rotation = rotated;
    while ((rotation - pi/2) >= 0)
        % Rotate in 90 degrees increment
        rotation = rotation - pi/2;

        % Save margins to rotate later
        origMargin.top    = portal.actualMargin.top;
        origMargin.bottom = portal.actualMargin.bottom;
        origMargin.left   = portal.actualMargin.left;
        origMargin.right  = portal.actualMargin.right;

        % Flip the portal size
        px = portal.size.x;
        py = portal.size.y;
        portal.size.x = py;
        portal.size.y = px;

        % Go through all the layers
        for i = 1:length(layers)
            m  = layers(i).getModel();
            vr = layers(i).viewRoot;

            % Move down and rotate 90 degrees
            rNode = m.createRotationNode(pi/2);
            if i == 1
                tNode = m.createTranslationNode(0, portal.viewExtent.width);
            else
                tNode = m.createTranslationNode(0, px);
            end
            m.addNodeAtIndex(vr, tNode, 0)
            m.addNodeAtIndex(vr, rNode, 1);
        end

        % Rotate view
        portal.viewExtent = Portal.BoundingBox( ...
            Portal.Point(portal.viewExtent.topLeftPt.y, ...
            -portal.viewExtent.topLeftPt.x), ...
            portal.viewExtent.height, ...
            portal.viewExtent.width);

        % Rotate margins
        portal.minimumMargin.top    = origMargin.right;
        portal.minimumMargin.bottom = origMargin.left;
        portal.minimumMargin.left   = origMargin.top;
        portal.minimumMargin.right  = origMargin.bottom;

    end
end

%-------------------------------------------------------------------------------
function locFixStateflowBackground(portal)
    % Manually add fake background because backgroundNode spills over the margin
    %
    % portal - print portal
    % id     - sf object
    %

    canvas = portal.getCanvas();
    layers = canvas.getLayers();
    glrcModel = layers(1).getModel();
    viewRoot = layers(1).viewRoot;

    % Turn off background node because it spills over the canvas margin.
    % Note: If we turn off Stateflow.SFGLRCRenderer.renderBackground, the
    % execution-order number's background color is white!!.  If we set the
    % background node after rendering the target, then the execute-order number's
    % background is retained!
    backgroundNode = find(viewRoot.getChildren, '-isa', 'DAStudio.GLRCBackgroundNodeRef');
    if isempty(backgroundNode)
        return
    end
    backgroundColor = backgroundNode.color;
    backgroundNodeIndex = glrcModel.getIndex(backgroundNode);
    glrcModel.removeNode(backgroundNode);

    % Add a separator to hold draw properties
    bkNode = glrcModel.createSeparatorNode();
    glrcModel.addNodeAtIndex(viewRoot, bkNode, backgroundNodeIndex);

    % Draw it!
    glrcModel.addNode(bkNode, glrcModel.createStrokeNode(backgroundColor));
    glrcModel.addNode(bkNode, glrcModel.createFillNode(backgroundColor));
    glrcModel.addNode(bkNode, glrcModel.createRectNode( ...
        portal.viewExtents.topLeftPt.x, ...
        portal.viewExtents.topLeftPt.y, ...
        portal.viewExtents.width, ...
        portal.viewExtents.height));

end

%-------------------------------------------------------------------------------
function coords = locRenderCallouts(this, portal, imgSize, margins, calloutSpace, calloutList)
    
    % Define callout rect where the callouts are along the outer edge of the
    % callout space.
    cRect = [margins.left - calloutSpace/2, ...
             margins.top - calloutSpace/2, ...
             imgSize(1) - margins.left - margins.right + calloutSpace, ...
             imgSize(2) - margins.top - margins.bottom + calloutSpace];

    callouts = DAStudio.Callouts( ...
        'Portal', portal, ...
        'CalloutRect', cRect);
    nCallouts = length(calloutList);
    
    coords = cell(3, nCallouts);
    for i = 1:nCallouts
        objPortalPos = this.getObjectPortalPosition(calloutList(i));
        coords{1, i} = calloutList(i);
        coords{2, i} = callouts.addAutoCallout(num2str(i), objPortalPos);
    end

end