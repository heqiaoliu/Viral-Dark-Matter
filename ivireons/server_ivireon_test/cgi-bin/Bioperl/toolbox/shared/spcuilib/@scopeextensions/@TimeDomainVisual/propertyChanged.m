function propertyChanged(this, ev)
%PROPERTYCHANGED React to changes in properties.

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.5.4.1 $ $Date: 2010/07/13 19:33:29 $

if ~ischar(ev)
    ev = get(ev.AffectedObject, 'Name');
end

switch ev
    case {'TimeRangeFrames' 'TimeRangeSamples'}
        value = this.getPropValue(ev);
        if strcmp(value, 'Spcuilib:scopes:TimeRangeInputSampleTime')
            if ~all(this.SampleTimes == 0)
                this.TimeRange = max(this.SampleTimes);
            end
        else
            evalProperty(this, ev, 'TimeRange');
            
            % Make sure we keep these in sync when we aren't using Input
            % Sample Time.
            if strcmp(ev, 'TimeRangeFrames')
                setPropValue(this, 'TimeRangeSamples', value, false);
                validateVisual(this.Application, this);
            elseif ~strcmp(getPropValue(this, 'TimeRangeFrames'), 'Spcuilib:scopes:TimeRangeInputSampleTime')
                setPropValue(this, 'TimeRangeFrames', value, false);
            end
        end
        
    case 'TimeDisplayOffset'
        evalProperty(this, 'TimeDisplayOffset');
    case 'InputProcessing'
        
        if strcmp(this.getPropValue('InputProcessing'), 'FrameProcessing');
            this.UpdateFcn = makeDrawFramesFunction;
            isFrames = true;
        else
            this.UpdateFcn = makeDrawSamplesFunction;
            isFrames = false;
        end
        
        % We need to redefine the display.
        onDataSourceChanged(this);
        
        % Update the TimeRange with the latest values.
        if isFrames
            propertyChanged(this, 'TimeRangeFrames');
        else
            propertyChanged(this, 'TimeRangeSamples');
        end
        
        % Validate the visual for the new input processing value.
        validateVisual(this.Application, this);
        
        % If we are rendered, make sure that we update the display.
        if ishghandle(this.Axes) && ~screenMsg(this.Application)
            source = this.Application.DataSource;
            if ~isempty(source)
                if ~validateSource(this, source)
                    return;
                end
                if isRunning(source)
                    update(this);
                else
                    update(this, getOriginTime(source), getTimeOfDisplayData(source));
                end
                clearPersistentLines(this);
            end
        end
        
    otherwise
        lineVisual_propertyChanged(this, ev);
end

% -------------------------------------------------------------------------
function fcn = makeDrawFramesFunction

fcn = @(h, varargin) drawFrames(h, varargin{:});

% -------------------------------------------------------------------------
function fcn = makeDrawSamplesFunction

fcn = @(h, varargin) drawSamples(h, varargin{:});

% [EOF]
