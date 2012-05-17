function runViewExt = getRuntimeViewExtents(this)
    % runViewExt is a structure with two fields, viewBox and scale

    % Copyright 2007 The Mathworks, Inc
    
    src = this.Source;

    switch this.ViewMode
        case 'current'
            if isa(src, 'Simulink.Object')
                % Get scaling
                runViewExt.scale = str2double(src.ZoomFactor)/100;

                % Calculate viewable extents
                loc = src.Location; % [x1 y1 x2 y2]
                scrollOffset = src.ScrollBarOffset;
                runViewExt.viewBox = [scrollOffset(1), ...
                                      scrollOffset(2), ...
                                      (loc(3) - loc(1)), ...
                                      (loc(4) - loc(2))] / runViewExt.scale;

            elseif isa(src, 'Stateflow.Object')
                % Get scaling, adjust for Stateflow Editor for using points
                editorScale = 1/src.Editor.ZoomFactor;
                runViewExt.scale = editorScale * this.convertToPixels(1, 'points');
          
                % Calculate viewable extents
                vLimits = sf('get', src.id, '.viewLimits'); % [x1 x2 y1 y2]
                runViewExt.viewBox = [vLimits(1), ...
                                      vLimits(3), ...
                                      (vLimits(2) - vLimits(1)), ...
                                      (vLimits(4) - vLimits(3))];

            else
                runViewExt.scale = 1;
                runViewExt.viewBox = [0 0 0 0];
            end
        
        case 'full'
            if isa(src, 'Simulink.Object')
                runViewExt.scale = 1;
            
            elseif isa(src, 'Stateflow.Object')
                %  adjust for Stateflow Editor for using points
                runViewExt.scale = this.convertToPixels(1, 'points');

            else
                runViewExt.scale = 1;
            end

            % Calculate full extents
            srcExtents = this.Portal.targetObjectExtents;
            runViewExt.viewBox = [srcExtents.topLeftPt.x, ... 
                                  srcExtents.topLeftPt.y, ...
                                  srcExtents.width, ...
                                  srcExtents.height];

        
        otherwise % 'custom'
            if ~isempty(this.ViewExtents)
                runViewExt.viewBox = this.ViewExtents;
                runViewExt.scale  = 1;

            else
                error('DAStudio:Snapshot:UndefinedViewExtents', ...
                    'View Extents is not defined!');
            end
    end

end
