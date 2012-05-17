function [fps, show, skip] = calculatePlaybackSchedule(this, ...
    fps, allowDecim, refreshMin, refreshMax)
%CALCULATEPLAYBACKSCHEDULE

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/06/13 15:28:43 $

% A user may ask for 100 fps; how will we achieve it?
% We set a schedule for the timer that is ideal for the
% human eye: approx 25-35 frames/sec is all it takes.
% Higher rates are achieved with frame drop - explicit,
% scheduled frame drops
%
%   this.Sourcefps      -> original rate of data source
%   this.Desiredfps     -> desired playback rate
%   this.Schedfps       -> rate we drive the timer
%   this.SchedShowCount -> part of schedule for frame playback
%   this.SchedSkipCount -> part of schedule for frame playback
%   this.SchedVerbose   -> show data
%   this.SchedRateMin   -> minimum timer rate
%   this.SchedRateMax   -> maximum timer rate
%   this.SchedEnable    -> disable scheduling (no drops)
%
%   If we show 3 then drop 1, showCount=3, skipCount=1
%        (1.33x increase in frame rate)
%   If we show 1 then drop 1, showCount=1, skipCount=1
%        (2x increase in frame rate)
%
%   (output rate) = (input rate) * (showCount+skipCount)/showCount
%
% "Good" schedules drive either showCount or skipCount to 1
% while maintaining a sched_fps close to 30 fps.
%
% Ex:
%   source rate: 29.97 fps
%   rateRange = [25 30]
%   fDesired = 46 fps
%   Creates burst schedule, show=3, skip=2, fact=27.6 fps

if nargin < 5
    refreshMax = this.SchedRateMax;
end
if nargin < 4
    refreshMin = this.SchedRateMin;
end
if nargin < 3
    allowDecim = this.SchedEnable;
end
if nargin < 2
    fps = this.DesiredFPS;
end

% The default is to show 1 frame and drop zero.
show = 1;
skip = 0;

if allowDecim
    % Compute a schedule based on frame drop and retiming
    rateScheduler;
end

% Debug info:
if this.SchedVerbose
    fprintf('sched_Decimate: show=%d, skip=%d, f_act=%g\n', ...
        show, skip, fps);
end

% -------------------------------------------------------------------------
    function rateScheduler
        %local_RateScheduler Determine an appropriate schedule using
        %   an ad-hoc search algorithm.
        %
        %   Uses .rateRange, a vector containing two elements:
        %   [fmin fmax], constraining the range of allowable rates for
        %   the timer object (i.e., the scheduler rate .sched_fps).
        %   The tighter the allowable range, the more work the scheduler
        %   must do to satisfy this constraint, and a potentially less-
        %   desirable frame scheduling may emerge.
        %
        %   More desirable to less desirable frame schedules:
        %      showCount=1, skipCount=N  (periodic decimation - visually appealing)
        %      showCount=N, skipCount=1  (bursts with periodic single-frame drop)
        %      showCount=N, skipCount>1  (longer sequences of frame drops)
        %
        %   The lower in this list we go, the more "jerky" the apparent motion
        %
        %   More optimal would be interpolated video sample rate conversion,
        %   but we don't offer that here due to computational overhead
        %   (we're trying to INCREASE playback rates, not DECREASE them!)
        
        % Techniques to try, in order:
        %
        success = sched_Decimate;
        if success, return; end
        
        % Try Burst with reasonable burst-skips
        % More than this and things look jerky in playback
        %  unless the show count is high comparatively
        maxSkip = 2;
        for Nskip = 1:maxSkip
            success = sched_Burst(Nskip);
            if success, return; end
        end
        
        % Fallback:
        warning(generatemsgid('PlaybackScheduleFailure'), ...
            ['Failed to find a playback schedule for ' ...
            'timer rates in the range %g to %g frames/sec.\n' ...
            'Using a simple schedule with %g frames/sec.  ' ...
            'Playback performance may be compromised.'], ...
            refreshMin, refreshMax, fps);
    end
% -------------------------------------------------------------------------
    function success = sched_Decimate
        %sched_Decimation
        %  Attempts schedules of the form
        %       showCount=1, skipCount=N
        %  This provides periodic decimation, and is visually appealing
        
        fo     = fps;  % desired "output" rate
        fi_min = refreshMin;
        fi_max = refreshMax;
        if fo <= fi_max
            % the desired frame rate is less than the maximum frame rate
            % we allow for the timer, so return a simple non-drop schedule
            success = true;
            return
        end
        
        % Compute possible skipCount values:
        Nmin = ceil((fo-fi_max)/fi_max);  % could be 0
        Nmax = floor((fo-fi_min)/fi_min); % could be 0
        if Nmax==0
            % Rates not high enough to support straight decimation
            success=false;
            return
        end
        % Create range of possible "skipCount" values
        Nrange = max(1,Nmin) : Nmax;
        % Compute corresponding actual timer rates
        fi_actual = fo ./ (Nrange+1);
        
        % Find actual rates that fall in range
        % All computed fi_actual values should be within rateRange constraint
        idx = find((fi_actual>=fi_min)&(fi_actual<=fi_max));
        if numel(idx) < numel(fi_actual)
            fprintf(['\nAssertion: decimation scheduler\n' ...
                'Computed candidate rate outside desired range\n' ...
                'fo=%g, rateRange=[%g %g]\n\n'],fo,fi_min,fi_max);
        end
        success = ~isempty(idx);  % failsafe
        if success
            % Given a range of acceptable rates, how should we choose?
            % Could choose highest acceptable rate, etc -> pros/cons
            % Here's what we'll do: middle of range
            %
            % pick "middle" index, closest to center of fi min/max range
            % in case of even # of entries, choose higher of the two
            nidx=numel(idx);       % all possible entries
            nidx=floor(1+nidx/2);  % choose middle, or higher or two if even
            idx=idx(nidx);         % get middle index from list of indices
            fps  = fi_actual(idx);
            skip = Nrange(idx);
            show = 1;
        end
    end
% -------------------------------------------------------------------------
    function success = sched_Burst(Nskip)
        %sched_Burst
        %  Attempts schedules of the form
        %       showCount=N, skipCount=Nskip, L=1,2,...
        %  This provides burst decimation, and is visually less appealing
        
        fo     = fps;
        fi_min = refreshMin;
        fi_max = refreshMax;
        if fo <= fi_max
            % should have been trapped by sched_Decimation, since that scheduler
            % is attempted before sched_Burst ... but just in case of a change:
            %
            % the desired frame rate is less than the maximum frame rate
            % we allow for the timer, so return a simple non-drop schedule
            success = true;
            return
        end
        
        % Compute possible showCount values:
        Nmax = floor(Nskip*fi_max/(fo-fi_max));  % could be 0
        Nmin = ceil(Nskip*fi_min/(fo-fi_min)); % could be 0
        
        if Nmax==0
            % Rates too high to support burst mode with this skip factor
            success=false;
            return
        end
        % Create range of possible "showCount" values
        Nrange = max(1,Nmin) : Nmax;
        % Compute corresponding actual timer rates
        fi_actual = fo .* Nrange./(Nrange+Nskip);
        
        % Find actual rates that fall in range
        % All computed fi_actual values should be within rateRange constraint
        idx = find((fi_actual>=fi_min)&(fi_actual<=fi_max));
        if numel(idx) < numel(fi_actual)
            fprintf(['\nAssertion: burst scheduler\n' ...
                'Computed candidate rate outside desired range\n' ...
                'fo=%g, rateRange=[%g %g]\n\n'],fo,fi_min,fi_max);
        end
        success = ~isempty(idx);  % failsafe
        if success
            % Given a range of acceptable rates, how should we choose?
            % Could choose highest acceptable rate, etc -> pros/cons
            % Here's what we'll do: middle of range
            %
            % pick "middle" index, closest to center of fi min/max range
            % in case of even # of entries, choose higher of the two
            nidx=numel(idx);       % all possible entries
            nidx=floor(1+nidx/2);  % choose middle, or higher or two if even
            idx=idx(nidx);         % get middle index from list of indices
            fps  = fi_actual(idx);
            skip = Nskip;
            show = Nrange(idx);
        end
    end
end

% [EOF]
