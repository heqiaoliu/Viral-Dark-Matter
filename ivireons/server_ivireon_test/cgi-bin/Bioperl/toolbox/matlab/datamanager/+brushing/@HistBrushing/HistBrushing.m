classdef (CaseInsensitiveProperties=true, TruncatedProperties=true, ConstructOnLoad=true) HistBrushing < hg2.Group

% Class for representing brushing graphics in histograms. This object
% must be parented to the hg2.Patch which draws the histogram bars.
% Brushing graphics are painted by the doUpdate method which reuses
% FaceHandle vertex data calculated in the parent hg2.Patch. So long as 
% this is the last child in the child order, that vertex data will be
% up to date and the brushing should never be a drawnow behind.
    
%  Copyright 2010 The MathWorks, Inc.

    % Property Definitions:    
    properties (SetObservable=true, SetAccess='public', GetAccess='public', Hidden=true )
        % Representation of the heights of brushed histogram bars
        BrushData; 
        % The brushing color expressed as an index into the figure
        % BrushStyleMap
        BrushColorIndex;
    end
           
    
    properties (SetObservable=true, SetAccess='private', GetAccess='public',  Hidden=true )
        BrushFaceHandles; 
    end
           
    
    
    methods
        function hObj = HistBrushing(varargin)
                        
            % Call the doSetup method:
            hObj.doSetup;
            
            % Pass any P/V pairs to the object:
            if ~isempty(varargin)
                set(hObj,varargin{:});
            end
        end
        
        function set.BrushData(hObj, newValue)
            % Cast the input to the specified type:
            newValue = hgcastvalue('NumericMatrix', newValue);
            reallyDoCopy = ~isequal(hObj.BrushData, newValue);
            if reallyDoCopy
               hObj.BrushData = newValue;
            end

            % Mark the object dirty.
            hObj.MarkDirty('all');
         end
      
    end
    
    % Methods Implementation
     
    
    methods(Access='private')
        function doSetup(hObj)

            addDependencyConsumed(hObj,'none');
            
            hObj.Internal = true;
            hObj.Serializable = 'off';
        end
    end
    methods(Access='public')
        function doUpdate(hObj, updateState)
            
            % Draw the brushing
            
            % Delete any existing brushing handles
            if ~isempty(hObj.BrushFaceHandles)
                delete(hObj.BrushFaceHandles);
                hObj.BrushFaceHandles = [];
            end

            % Exclude nonlinear data space until histograms use a charting
            % object.
            brushData = hObj.BrushData;
            if isempty(brushData) || strcmp(updateState.DataSpaceHandle.isLinear,'off') || ...
                    isempty(hObj.Parent) || isempty(hObj.BrushColorIndex) || ...
                    hObj.BrushColorIndex==0
                return
            end
            
            % Find the figure BrushStyleMap, if it has been defined, and make sure
            % it is a nx3 matrix otherwise revert to the default.
            brushStyleMap =  matlab.graphics.chart.primitive.brushingUtils.getBrushStyleMap(hObj);
            
            % Look-up the brush color in the BrushStyleMap
            brushColor = matlab.graphics.chart.primitive.brushingUtils.getBrushingColor(hObj.BrushColorIndex,brushStyleMap);
            if isempty(brushColor)
                return
            end
            
            % Create primitive brushing objects for each brushing layer
            brushFaceHandle = matlab.graphics.primitive.world.Triangle('Parent',hObj);
            brushFaceHandle.ColorBinding = 'object';
            brushFaceHandle.Parent = hObj;
            brushFaceHandle.Hittest = 'on';
            addlistener(brushFaceHandle,'Hit',@(es,ed)  matlab.graphics.chart.primitive.brushingUtils.addBrushContextMenuCallback(hObj,ed));


            
            % Find the vertices of the histogram non-zero bar tops in camera
            % coordinates by scaling the Y values of the primitive face
            % handle vertices. Note, this will only work for linear data
            % spaces.
            [vData,baseValue] = brushing.HistBrushing.histBarCameraCoords(hObj.Parent);
            binHeights = hObj.Parent.YData(2,:);
            posBinHeights = binHeights>0; % Zero bars have no vertices
            binHeights = binHeights(posBinHeights);
            binBrushRatios = brushData(posBinHeights)./binHeights;
            vBrushData = vData;
            vBrushData(2,:) = baseValue+(vData(2,:)-baseValue).* ...
                reshape([binBrushRatios;binBrushRatios],[1 2*length(binBrushRatios)]);
            
            % Use the scaled histogram vertices to define a simple
            % triangulation.
            vData = baseValue*ones([3 size(vBrushData,2)*3],'single');
            vData(1,1:6:end) = vBrushData(1,1:2:end);
            vData(1,2:6:end) = vBrushData(1,1:2:end);
            vData(1,5:6:end) = vBrushData(1,1:2:end);
            vData(1,3:6:end) = vBrushData(1,2:2:end);
            vData(1,4:6:end) = vBrushData(1,2:2:end);
            vData(1,6:6:end) = vBrushData(1,2:2:end);           
            vData(2,2:6:end) = vBrushData(2,1:2:end);
            vData(2,5:6:end) = vBrushData(2,1:2:end);
            vData(2,6:6:end) = vBrushData(2,1:2:end);           
            brushFaceHandle.VertexData = vData;
            brushFaceHandle.StripData = [];
      
            
            % Find the brushing color and assign it to the brushing objects
            brushFaceHandle.ColorData = matlab.graphics.chart.primitive.brushingUtils.transformBrushColorToTrueColor(...
                    brushColor,updateState);
            
            hObj.BrushFaceHandles = brushFaceHandle;
        end
    end
    
    
       methods(Access='public', Static=true)
            % Extract the camera space coordinates for the tops of histogram
            % bars in a manner which is independent of the triangulation
            % algorithm by finding the horizontal top edges of all the
            % triangles and where there is overlap choosing the one with the
            % larger y value.
            function [topEdges,baseValue] = histBarCameraCoords(h)
                vdata = h.FaceHandle.VertexData;

                if ~isempty(h.FaceHandle.VertexIndices)
                    vdata = vdata(:,h.FaceHandle.VertexIndices+1);
                end
                topEdgesLeft = [];
                topEdgesRight = [];
                baseValue = [];
                if isempty(vdata)
                    return
                end
                
                % Patch primitives can be triangles or quads.
                istriangle = isa(h.FaceHandle,'matlab.graphics.primitive.world.Triangle');

                % Note that StripData should not make any difference since
                % detecting the horizontal tops of triangles is not influenced
                % by how verices are connected.

                % Loop through each triangle/quad. If the triangle/quad 
                % could be connected to have a horizontal top edge, add 
                % the left and right vertices of that potential edge to the 
                % the topEdgesLeft and topEdgesRights arrays.            
                for k=1:(3+~istriangle):floor(size(vdata,2))
                    if istriangle
                        triangle = vdata(:,k:k+2);
                        I = find(max(triangle(2,:))==triangle(2,:));
                        if length(I)==2
                            if triangle(1,I(1))<=triangle(1,I(2))
                                topEdgesLeft = [topEdgesLeft,triangle(:,I(1))]; %#ok<AGROW>
                                topEdgesRight = [topEdgesRight,triangle(:,I(2))]; %#ok<AGROW>
                            else                                  
                                topEdgesLeft = [topEdgesLeft,triangle(:,I(2))]; %#ok<AGROW>
                                topEdgesRight = [topEdgesRight,triangle(:,I(1))]; %#ok<AGROW>
                            end
                        end
                    else % This is a quad
                        quad = vdata(:,k:k+3);
                        I = find(max(quad(2,:))==quad(2,:));
                        if length(I)>=2
                            [~,Ixleft] = min(quad(1,I));
                            [~,Ixright] = max(quad(1,I));
                            topEdgesLeft = [topEdgesLeft,quad(:,I(Ixleft(1)))]; %#ok<AGROW>
                            topEdgesRight = [topEdgesRight,quad(:,I(Ixright(1)))]; %#ok<AGROW>
                        end
                    end
                end 
                baseValue = min(vdata(2,1:end));
                if isempty(topEdgesLeft)
                    return
                end

                % Sort the topEdges arrays first in descending Y then in
                % acending X.
                [~,I] = sort(topEdgesLeft(2,:),'descend');
                topEdgesLeft = topEdgesLeft(:,I);
                topEdgesRight = topEdgesRight(:,I);
                [~,I] = sort(topEdgesLeft(1,:));
                topEdgesLeft = topEdgesLeft(:,I);
                topEdgesRight = topEdgesRight(:,I);

                % Accumulate all the top (in y) line segments as the vertices
                % of the tops of the histogram bars in camera coordinates
                topEdges = [topEdgesLeft(:,1) topEdgesRight(:,1)];
                for k=2:size(topEdgesLeft,2)
                    % Accumulate the next line segment if it begins in x after
                    % the last one ends. Note that because topEdgesLeft is
                    % secodondarily sorted in descending y, if there are
                    % multiple line segments meeting this condition with the
                    % same x, the first one will have the greater y value.
                    if topEdgesLeft(1,k)>=topEdges(1,end)
                        topEdges = [topEdges topEdgesLeft(:,k) topEdgesRight(:,k)]; %#ok<AGROW>
                    end
                end
            end
       end

    
end
