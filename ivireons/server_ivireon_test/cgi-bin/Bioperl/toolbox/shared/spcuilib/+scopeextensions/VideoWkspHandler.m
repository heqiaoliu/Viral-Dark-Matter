classdef VideoWkspHandler < scopeextensions.AbstractWkspHandler
    %VIDEOWKSPHANDLER Define the VideoWkspHandler class.
    
    %   Copyright 2008-2010 The MathWorks, Inc.
    %   $Revision: 1.1.6.14 $  $Date: 2010/05/20 03:07:38 $
    
    methods
        function this = VideoWkspHandler(srcObj, varargin)
            %VIDEOWKSPHANDLER Construct a VIDEOWKSPHANDLER object
            
            oldName = srcObj.Name;
            oldNameShort = srcObj.NameShort;
            
            this@scopeextensions.AbstractWkspHandler(srcObj, ...
                scopeextensions.VideoData, varargin{:});
            
            if strcmp(this.ErrorStatus, 'failure')
                return;
            end
            
            if this.Data.FrameRate > 100
                this.Data.FrameRate = 100;
                uiscopes.errorHandler({ ...
                    sprintf('Frame rate cannot exceed 100 frames/sec.'), ...
                    'Setting rate to maximum.'});
            end

            [this.UserData, this.Data.ColorSpace, ...
                arrayFormat, this.Data.ColorMap, errMsg] = ...
                scopeextensions.VideoData.checkVideoFormat(this.UserData);
            
            if ~isempty(errMsg)
                this.ErrorStatus = 'failure';
                this.ErrorMsg = errMsg;
                srcObj.Name = oldName;
                srcObj.NameShort = oldNameShort;
                return;
            end
                        
            % Get video frame size
            switch arrayFormat
                case 'array'
                    % MxNxT or MxNx3xT
                    this.Data.DataType  = class(this.UserData);
                    dims = size(this.UserData);
                    this.Data.Dimensions = dims(1:2);
                    if ndims(this.UserData) == 2
                        nFrames = 1;
                    else
                        nFrames = dims(end);
                    end
                    this.Data.NumFrames = nFrames;
                case 'struct'
                    
                    % Set the colormap into the visual.
                    srcObj.Application.Visual.setPropValue('ColorMapExpression', mat2str(this.UserData(1).colormap))
                    % struct contains invidividual frames
                    % MxN or MxNx3
                    % we guarantee at least 1 entry
                    this.Data.DataType  = class(this.UserData(1).cdata);
                    dims = size(this.UserData(1).cdata);
                    this.Data.Dimensions = dims(1:2);
                    this.Data.NumFrames = numel(this.UserData);  % a scalar in this case
            end
            
            % If we made it here, we've successfully initialized the data source
            switch arrayFormat
                case 'struct'
                    this.FrameFcn = @get_struct_frame;
                otherwise % 'array'
                    switch this.Data.ColorSpace
                        case 'intensity'
                            this.FrameFcn = @get_intensity_array_frame;
                        otherwise % 'rgb'
                            this.FrameFcn = @get_rgb_array_frame;
                    end
            end
        end
        
        function d = getTimeDimension(this, varargin)
            
            if isstruct(this.UserData)
                d = numel(size(this.UserData(1).cdata))+1;
            else
                % The minimum time dimension is the third dimension.
                d = getTimeDimension@scopeextensions.AbstractWkspHandler(this, varargin{:});
            end
            
            d = max(3, d);

            
        end
        
    end
    methods (Static = true)
        function [valid, errMsg] = isDataValid(myData)
            valid = false;
            % check if the data is valid video data
            [~, ~, ~, ~, errMsg] = scopeextensions.VideoData.checkVideoFormat(myData);
            if isempty(errMsg)
                valid = true;
            end
            
        end
    end
end

% -------------------------------------------------------------------------
function y = get_struct_frame(this,idx)

if ~isempty(this.UserData)
    y = this.UserData(idx).cdata;
else
    y = [];
end
end

% -------------------------------------------------------------------------
function y = get_intensity_array_frame(this,idx)

if ~isempty(this.UserData)
    y = this.UserData(:,:,idx);
else
    y = [];
end
end

% -------------------------------------------------------------------------
function y = get_rgb_array_frame(this,idx)

if ~isempty(this.UserData)
    y = this.UserData(:,:,:,idx);
else
    y = [];
end
end

% [EOF]
