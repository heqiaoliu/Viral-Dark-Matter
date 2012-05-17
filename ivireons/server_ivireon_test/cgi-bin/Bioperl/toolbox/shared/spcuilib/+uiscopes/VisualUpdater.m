classdef (Sealed) VisualUpdater < handle
    %VisualUpdater   Define the VisualUpdater class.
    %
    %    VisualUpdater methods:
    %        attach - Attach a source to the updater.
    %        detach - Detach a source from the updater.
    %
    %    VisualUpdater properties:
    %        Instance - The Singleton instance of the updater.
    
    %   Copyright 2009-2010 The MathWorks, Inc.
    %   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:40:58 $
    
    % Create a Constant, Hidden property to store the Instance.  This means
    % it is set once at class read-time enabling this class to be Singleton
    % (along with the private constructor).  It is Hidden so that it does
    % not show up in the default display.
    properties (Hidden, Constant)
        
        % Instance is a Constant property which stores the singleton
        % instance to the uiscopes.VisualUpdater object.
        Instance = uiscopes.VisualUpdater;
    end

    properties (SetAccess = private)
        
        % Sources hold all of the source objects that have been attached.
        Sources = [];
        Count = 0;
        Period = .05;
    end
    
    properties (Access = private)
        
        % Timer holds the handle to a timer object that is used to
        % periodically update all simulink source Visual fields.
        Timer = [];
    end
    
    methods (Access = private)
        
        function this = VisualUpdater
            %VisualUpdater   Construct the VisualUpdater class.
            
            % Call MLOCK to avoid clear classes warnings.
            mlock;
        end
    end
    
    methods
        
        function attach(this, hSource)
            
            % Add the new source to the list of sources.
            this.Sources = union(this.Sources, hSource);
            
            % Get the stored timer.
            modelTimer = this.Timer;
            
            % If it is empty, create a new one and save it.
            if isempty(modelTimer)
                
                modelTimer = timer( ...
                    'ExecutionMode', 'fixedRate', ...
                    'Period', this.Period, ...
                    'TimerFcn', makeTimerCallback(this));
            
                this.Timer = modelTimer;
                
                % Start the timer as soon as we have 1 source attached.
                start(modelTimer);
            end
        end
        
        function detach(this, hSource, update)
            
            if nargin < 3
                update = true;
            end
            
            if nargin > 1
                
                oldSources = this.Sources;
                newSources = setdiff(oldSources, hSource);
                
                % If we are not actually removing the source, do not try to
                % update it.  It was never added to the updater.
                if numel(oldSources) == numel(newSources)
                    update = false;
                end
                
                % Remove the passed source from the stored sources vector.
                this.Sources = newSources;
            else
                
                % If no source is passed, we detach them all.
                this.Sources = [];
            end
            
            % If we have no more sources, or no source was passed, stop and
            % delete the timer.
            if isempty(this.Sources)
                
                % If we have a timer, stop & delete it.
                hTimer = this.Timer;
                if ~isempty(hTimer) && isvalid(hTimer)
                    
                    % Clear out the timer first so that we cannot re-enter
                    % this code.
                    this.Timer = [];
                    
                    % Stop the Timer.
                    if ~isempty(hTimer) && isvalid(hTimer)
                        stop(hTimer);
                    end
                    
                    % Delete the timer to avoid leaks.
                    if ~isempty(hTimer) && isvalid(hTimer)
                        delete(hTimer);
                    end
                    
                    % Reset the TimeStatus counter.
                    this.Count = 0;
                end
            end
            
            % Fire the callback one last time for the stopped source.  This
            % will effectively stop the timer for this source.
            if nargin > 1 && update
                
                try
                    % We only need to update the visual when there is new data.
                    updateVisual(hSource);
                    
                    % Always update the TimeStatus
                    updateTimeStatus(hSource);
                catch ME %#ok<NASGU>
                    % This is a no-op.  Chances are we are stopping because
                    % this visual errored out.  Do not rethrow the error.
                end
            end
        end
    end
end

% -------------------------------------------------------------------------
function cb = makeTimerCallback(this)

% Create the callback.  This local function insures that there are no extra
% variables passed in the anonymous workspace.
cb = @(varargin) lclUpdate(this);

end

% -------------------------------------------------------------------------
function lclUpdate(this)

hSources = this.Sources;

% If we have no attached sources, stop the timer via the detach method.
if isempty(hSources)
    detach(this);
    return;
end

this.Count = this.Count+1;

% We only update the time status no faster than 2 Hz regardless of how fast
% we update the visual.
shouldUpdateTimeStatus = this.Count*this.Period > .5;

for indx = 1:numel(hSources)
    try
        updateVisual(hSources(indx));
        if shouldUpdateTimeStatus
            
            % Reset the count so that we can keep track of how long it has been
            % since we updated the time status.
            this.Count = 0;
            
            % Update the time status of each source.
            updateTimeStatus(hSources(indx));
        end
    catch ME %#ok
        
        % If an error occurs while updating the time status, remove the
        % source which caused the error.
        detach(this, hSources(indx), false);
    end
end
end

% [EOF]
