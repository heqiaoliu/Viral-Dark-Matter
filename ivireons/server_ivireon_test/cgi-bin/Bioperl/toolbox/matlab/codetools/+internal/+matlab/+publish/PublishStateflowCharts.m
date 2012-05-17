classdef PublishStateflowCharts < internal.matlab.publish.PublishFigures
% Copyright 1984-2009 The MathWorks, Inc.

    methods
        function obj = PublishStateflowCharts(options)
            obj = obj@internal.matlab.publish.PublishFigures(options);
        end
    end
    
    methods(Static)
        function imgFilename = snapFigure(f,imgNoExt,opts)
            % Nail down the image format.
            if isempty(opts.imageFormat)
                imageFormat = internal.matlab.publish.getDefaultImageFormat(opts.format,'print');
            else
                imageFormat = opts.imageFormat;
            end

            % Nail down the image filename.
            imgFilename = internal.matlab.publish.getPrintOutputFilename(imgNoExt,imageFormat);
            
            % Reconfigure the figure for better printing.
            params = {'PaperOrientation','Units','PaperPositionMode'};
            tempValues = {'portrait','pixels','auto'};
            origValues = get(f,params);
            set(f,params,tempValues);
            
            imWidth = opts.maxWidth;
            imHeight = opts.maxHeight;
            
            % Get information about the Stateflow chart.
            sfid = get(f,'UserData');
            sfobj = idToHandle(sfroot, sfid);
            model = sfobj.Machine.Name;
            
            % Capture original Stateflow settings.
            origDirty = get_param(model,'Dirty');
            sfParams = {'PaperPosition','PaperOrientation','PaperPositionMode'};
            origSfValues = get(sfobj,sfParams);
            
            % Set up paper properties to match the editor.
            set(sfobj,sfParams,get(f,sfParams))
            
            % Make the diagram big so we can resize it down to the size we
            % want later.
            set(sfobj,'PaperPosition',get(sfobj,'PaperPosition').*10)
            
            % Print the diagram.
            sfprint(sfid,imageFormat,imgFilename)
            
            % Restore original Stateflow settings.
            set(sfobj,sfParams,origSfValues)
            set_param(model,'Dirty',origDirty);
            
            % Setup the file to be resized to screen resolution.
            figurePosition = get(f,'Position');
            toolbarWidth = 38;
            scrollbarWidth = 18;
            chartWidth = figurePosition(3)-toolbarWidth-scrollbarWidth;
            if isempty(imWidth) || (imWidth > chartWidth)
                imWidth = chartWidth;
            end
            
            % Restore the figure.
            set(f,params,origValues);
            
            internal.matlab.publish.resizeIfNecessary(imgFilename,imageFormat,imWidth,imHeight)
        end
    end
end

