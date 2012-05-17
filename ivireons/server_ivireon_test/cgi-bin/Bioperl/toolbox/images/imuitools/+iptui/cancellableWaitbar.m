% This undocumented class may be removed in a future release.

%   obj = cancellableWaitbar(dlgName, statusFormatter, totalImages, processedImages)
%
%   The title of the dialog will be:  DLGNAME [X]% completed.  So a typical
%   value for dlgName might be:
%
%       'Block Processing:'
%
%   There are 2 lines of text that appear above the actual wait bar.  The
%   top line is defined by the STATUSFORMATTER.  The status formatter 
%   should contain a "%d", where it will receive the total number of images
%   to be processed.  For example a status formatter might look like:
%
%       'Processing %d blocks'
%
%   TOTALIMAGES should be the total number of images/elements that the
%   waitbar will process.  PROCESSEDIMAGES should be the number of
%   images/elements (out of TOTALIMAGES) that were processed BEFORE
%   creating the waitbar.
%
%   The UPDATE(PROCESSED_IMAGES) method will update the wait bar.
%   PROCESSED_IMAGES should be the total number of images that are
%   completed, including any that may have been processed before the
%   waitbar was created (the PROCESSEDIMAGES from the constructor).  If the
%   argument is omitted, the waitbar just increments by 1.

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $ $Date: 2010/03/04 16:21:11 $

classdef cancellableWaitbar < handle
    
    properties (SetAccess = 'private',GetAccess = 'public')
        
        % gui components
        hWait
        dlgName
        statusFormatter
        cancelPressed
        % image counters
        totalImages
        processedImages
        lastUpdateImage
        % times
        startTime
        lastTime
        % timing buffers
        updateTimes
        updateStepSizes
        % time strings
        isCalculating
        elapsedTimeStr
        estimatedTimeStr
        
    end % properties
    
    
    methods (Access = 'public')
        
        function obj = cancellableWaitbar(dlgName, statusFormatter, totalImages, processedImages)
            
            % dialog properties
            obj.dlgName = dlgName;
            obj.statusFormatter = statusFormatter;
            
            % initial images processed
            obj.totalImages = totalImages;
            if nargin > 3
                obj.processedImages = processedImages;
            else
                obj.processedImages = 0;
            end
            obj.lastUpdateImage = obj.processedImages;
            
            % initialize all flags / counters / strings
            obj.cancelPressed = false;
            obj.estimatedTimeStr = 'Calculating...';
            obj.updateTimes = [];
            obj.updateStepSizes = [];
            obj.isCalculating = true;
            
            % create waitbar dialog
            obj.hWait = waitbar(0, '', 'CreateCancelBtn', @obj.cancel);
            set(obj.hWait, 'CloseRequestFcn', @obj.cancel);
            
            % Put the percentage done in the figure title, so it shows up
            % when minimized.
            percent_done = round(100 * (obj.processedImages / obj.totalImages));
            set(obj.hWait, 'Name', sprintf('%s %d%% completed', obj.dlgName,percent_done));
            
            % start timing
            obj.startTime = tic;
            obj.lastTime = obj.startTime;

            % do a single update
            obj.update(obj.processedImages);
            
        end
        
        
        function update(obj,processed_images)
            
            if isempty(obj.hWait)
                return
            end
            
            % increment our counter
            if nargin > 1
                obj.processedImages = processed_images;
            else
                obj.processedImages = obj.processedImages + 1;
            end
            
            % update at most once per second (updates are expensive)
            current_time = toc(obj.lastTime);
            if current_time < 1
                return
            end
            
            % we are going to update, how big is this update?
            current_step_size = obj.processedImages - obj.lastUpdateImage;
            
            % update time estimates
            obj.updateTimeEstimates(current_time,current_step_size);
            
            % update dialog text and bar
            pct = min((obj.processedImages / obj.totalImages), 1);
            if obj.isCalculating
                status_msg = sprintf([obj.statusFormatter '\nTime: Calculating...'],...
                    obj.totalImages);
            else
                status_msg = sprintf([obj.statusFormatter '\nTime: %s of %s'],...
                    obj.totalImages,obj.elapsedTimeStr,obj.estimatedTimeStr);
            end                
            % update waitbar
            waitbar(pct, obj.hWait,status_msg);
            set(obj.hWait, 'Name', sprintf('%s %d%% completed',...
                obj.dlgName,round(100*pct)));
            
            % reset counters
            obj.lastUpdateImage = obj.processedImages;
            obj.lastTime = tic;
            
        end
        
        
        function destroy(obj)
            
            delete(obj.hWait);
            obj.hWait = [];
            
        end
        
        
        function cancel(obj, varargin)
            
            obj.destroy;
            obj.cancelPressed = true;
            
        end
        
        
        function tf = isCancelled(obj)
            
            tf = obj.cancelPressed;
            
        end
        
    end % public methods
    
    
    methods (Access = 'private')
        
        function updateTimeEstimates(obj,current_time,current_step_size)
            
            % udpate elapsed time string
            elapsed_time = toc(obj.startTime);
            obj.elapsedTimeStr = getTimeStr(elapsed_time);
            
            % update our set of times
            timeBufferSize = 5;
            if numel(obj.updateTimes) < timeBufferSize
                
                % add to buffer of update times
                obj.updateTimes     = [current_time obj.updateTimes];
                obj.updateStepSizes = [current_step_size obj.updateStepSizes];
                
            else
                
                % set flag
                obj.isCalculating = false;
                % update buffer of update times
                obj.updateTimes = [current_time obj.updateTimes(1:timeBufferSize-1)];
                obj.updateStepSizes = [current_step_size obj.updateStepSizes(1:timeBufferSize-1)];
                % compute new estimate
                timePerImage = sum(obj.updateTimes) / sum(obj.updateStepSizes);
                remainingTime = timePerImage * (obj.totalImages - obj.processedImages);
                estTotalTime = elapsed_time + remainingTime;
                obj.estimatedTimeStr = getTimeStr(estTotalTime);
                
            end
            
        end
        
    end % private methods
    
end % classdef


function str = getTimeStr(time)

% convert to serial date number (units == days)
seconds_per_day = 60 * 60 * 24;
time = time / seconds_per_day;

hour = 1/24;
if time > hour
    str = datestr(time, 'HH:MM:SS');
    if str(1) == '0'
        str(1) = '';
    end
else
    str = datestr(time, 'MM:SS');
end

end

