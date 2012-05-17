% This internal helper class may change in a future release.

%  Copyright 2008-2010 The MathWorks, Inc.

% Class to for drawing a selection rectangle or prisms for brushing data. 
% An object should be created on a mouse down event, and the prism drawn by
% calling draw on mouse motion. The reset method should be called on the 
% object on a mouse up to clear the selection graphic.

classdef (CaseInsensitiveProperties = true, Hidden = true) select < handle
    properties
        ScribeLayer = [];
        AxesStartPoint = [];
        ScribeStartPoint = [];
        Figure = [];
        Axes = [];
        Graphics = [];
    end

    methods
        function this = select(hostAxes)
            this.Figure = ancestor(hostAxes,'figure');
            this.Axes = hostAxes;
            this.ScribeLayer = double(graph2dhelper('findScribeLayer',this.Figure));
            this.AxesStartPoint = get(hostAxes,'CurrentPoint');
            this.ScribeStartPoint = get(this.Figure,'CurrentPoint'); 
        end
        function reset(this)
            if ~isempty(this.Graphics) && ((isobject(this.Graphics) && ...
                    isvalid(this.Graphics)) || (~isobject(this.Graphics) && ...
                    ishandle(this.Graphics)))
                delete(this.Graphics);
            end
           
            this.Graphics = [];
            this.ScribeLayer = [];
            this.Figure = [];
            this.Axes = [];           
        end
    end
    
    methods (Static = true)
    
        function pixelLocation = transformCameraToFigCoord(ax,pt)
            % pt is an 3 by n array
            ax = ancestor(ax,'axes');
            if isempty(ax)
                pixelLocation = [];
                return;
            end
            hCamera = ax.CameraHandle;
            
            % Take the point and multiply it by the camera transforms
            projectionMatrix = hCamera.GetProjectionMatrix;
            viewMatrix = hCamera.GetViewMatrix;
            % Assume the model matrix is the identity matrix (for now).
            modelMatrix = eye(4);
            hDataSpace = ax.DataSpaceHandle;
            if strcmp(hDataSpace.isLinear,'on')
                modelMatrix = modelMatrix * hDataSpace.getMatrix;
            end
            totalMatrix = projectionMatrix * viewMatrix * modelMatrix;
            point = totalMatrix * [pt; ones(1,size(pt,2))];
            
            % Scale to the viewport
            viewport = hCamera.Viewport;
            viewport.Units = 'pixels';
            viewportPosition = viewport.Position;
                
            pixelLocation = zeros(2,size(pt,2));
            I = point(4,:) > 0;
            point(1,I) = point(1,I)./point(4,I);
            point(2,I) = point(2,I)./point(4,I);
            pixelLocation(:,I) =  [viewportPosition(1)+viewportPosition(3) * (1+point(1,I))/2;...
                        viewportPosition(2)+viewportPosition(4) * (1+point(2,I))/2]; 
        
        end
        
        % Static method for determining the indices of points enclosed in a
        % polygon. Based on similar code in
        % vertexpickerHGUsingMATLABClasses.m except here there is only one
        % polygon and there may be multiple points.
         function ind_intersection_test = inpolygon(pixelLocations,points)
          
            % Remove any duplicated vertices in the polygon without
            % otherwise modifying the pixel order
            [~,I] = unique(pixelLocations','rows');         
            pixelLocations = pixelLocations(:,sort(I));
            numVertices = size(pixelLocations,2);
            
            ind_intersection_test = false(size(points,2),1);
            for k=1:size(points,2)
                % Begin by subtracting out each point to normalize the coordinates:
                % Store the old pixel locations:
                polyLocation = pixelLocations - points(:,k)*ones(1,numVertices);

                % Find all vertices that have y components less than zero
                vert_with_nonpositive_y = polyLocation(2,:)<=0;

                % Find all the line segments that span the x axis
                is_line_segment_spanning_x = abs(diff([vert_with_nonpositive_y, vert_with_nonpositive_y(1)]));

                % Does the face have a line segments that span the x axis
                if any(is_line_segment_spanning_x)     
                     startPts = polyLocation;
                     endPts = polyLocation(:,[2:end 1]);
                     cross_product_test = -startPts(1,:).*(endPts(2,:)-startPts(2,:)) > -startPts(2,:).*(endPts(1,:)-startPts(1,:));
                     crossing_test = (cross_product_test==vert_with_nonpositive_y) & is_line_segment_spanning_x;
                     % If the number of line segments is odd, then we intersected 
                     % the polygon (Jordan Curve Theorem)
                     ind_intersection_test(k) = ~(mod(sum(crossing_test),2)==0);
                end
                
                % ind_intersection_test(k) will be false the face was not
                % hit. We may, however, still have intersected a vertical
                % edge.
                if ~ind_intersection_test(k)
%                     ind_intersection_test(k) = any(~(polyLocation(1,:) | ...
%                         [polyLocation(1,2:end) polyLocation(1,1)]));
                    I = find(~(polyLocation(1,:) | ...
                        [polyLocation(1,2:end) polyLocation(1,1)]));
                    if ~isempty(I)
                        if I(1)<size(polyLocation,2)
                           ind_intersection_test(k) = (polyLocation(2,I(1))*...
                              polyLocation(2,I(1)+1)<=0);
                        else
                           ind_intersection_test(k) = (polyLocation(2,1)*...
                              polyLocation(2,end)<=0);
                        end
                    end
                end
                   
            end
            ind_intersection_test = find(ind_intersection_test); 
         end
        
         % Temporary hittest function to detect axes. Used until g596568 is
         % fixed.
         function hitobj = axeshittest(fig)
            hitobj = [];
            allAxes = findall(fig,'type','axes');
            mousePos = get(fig,'CurrentPoint');
            for k=1:length(allAxes)
                axFigPos = hgconvertunits(fig,getpixelposition(allAxes(k)),...
                    'pixels',get(fig,'Units'),fig);
                if mousePos(1)>=axFigPos(1) && mousePos(1)<=axFigPos(1)+...
                        axFigPos(3) && mousePos(2)>=axFigPos(2) && ...
                        mousePos(2)<=axFigPos(2)+axFigPos(4)
                    hitobj = allAxes(k);
                    break;
                end
            end
         end
                  
        % Extract a horizontal concatenation of the selected graphic object data
        % from an unlinked plot graphic
        function selectedData = getArraySelection(this)

            selectedData = [];
            ydata = get(this,'YData');
            xdata = get(this,'XData');
            if isprop(this,'ZData')
                zdata = get(this,'ZData');
                % For non-series objects , expand the xdata and ydata
                % vectors to match a zdata matrix
                if ~isempty(zdata) && ~isvector(zdata)
                    if isvector(xdata)
                        xdata = repmat(xdata(:)',[size(zdata,1) 1]);
                    end
                    if isvector(ydata)
                        ydata = repmat(ydata(:),[1 size(zdata,2)]);
                    end
                else
                   zdata = zdata(:);
                   ydata = ydata(:);
                   xdata = xdata(:);
                end
            else
                zdata = [];
                ydata = ydata(:);
                xdata = xdata(:);
            end

            % zdata is empty or a vector for 1-d graphic objects such as
            % lines and bars.
            if isempty(zdata) || isvector(zdata)
                I = any(this.BrushData>0,1);
                if ~isempty(I)
                    if isempty(zdata)
                        selectedData = [xdata(I),ydata(I)];
                    else
                        selectedData = [xdata(I),ydata(I),zdata(I)];
                    end
                end
            % If zdata is a matrix the graphic is a surface or a mesh and 
            % selectedData is a concatenation of the xdata, ydata, zdata of
            % the smallest enclosing rectangle.
            else
                I = this.BrushData>0;
                Icols = any(I,1);
                Irows = any(I,2);
                xdata = xdata(Irows(:),Icols(:));
                ydata = ydata(Irows(:),Icols(:));
                zdata = zdata(Irows(:),Icols(:));         
                selectedData = [xdata;ydata;zdata];  
            end    
        end
        
        
        function clearBrushing(ax)
            % Clear linked variable brushing when using MCOS graphics
            fig = handle(ancestor(ax,'figure'));
            brushMgr = datamanager.brushmanager;
            if isprop(fig,'LinkPlot') && fig.LinkPlot    
                [mfile,fcnname] = datamanager.getWorkspace(2);
                brushMgr.clearLinked(fig,ax,mfile,fcnname);
            end
            brushMgr.clearUnlinked(ax);
        end
    end
end