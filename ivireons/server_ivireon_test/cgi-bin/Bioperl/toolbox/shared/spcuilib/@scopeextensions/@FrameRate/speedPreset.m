function newFPS = speedPreset(this,dir)
%SpeedPreset Change playback rate to a preset value.
%  val:
%    '+': increment speed to next enumeration
%         if currently 'unknown', goes to '0'
%    '-': decrement speed to next enumeration
%         if currently 'unknown', goes to '0'
%    '0': goes to datasource frame rate
%
% Note: if playback speed is currently not an enumerated value
%       (i.e., a frame rate was manually entered prior to the +/- key),
%       we skip to the NEXT CLOSEST enumerated playback rate in the
%       appropriate direction (+:faster, -:slower)

% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2008/02/02 13:10:13 $

if this.speedPreset == 0  % "unknown" or "arbitrary" setting
    % Not currently on a "preset"
    % Move to nearest value in the appropriate direction
    
    rate_ratio = this.Desiredfps / this.Sourcefps;
    switch dir
        case '+'
            % Choose enumerated rate just higher than current rate
            enum = find(rate_ratio < this.speedPresetCurr, 1, 'first');
            if isempty(enum)
                % arbitrary rate is higher than highest preset
                % take highest rate
                this.speedPreset = this.speedPresetCurr(end);
            else
                this.speedPreset = this.speedPresetCurr(enum);
            end
        case '-'
            % Choose enumerated rate just lower than current rate
            enum = find(rate_ratio > this.speedPresetCurr, 1, 'last');
            if isempty(enum)
                % arbitrary rate is lower than lowest preset
                % take lowest rate ratio
                this.speedPreset = this.speedPresetCurr(1);
            else
                this.speedPreset = this.speedPresetCurr(enum);
            end
        otherwise % case '0', reset to 100% (full speed)
            this.speedPreset = 1.0;
    end
    
else
    % Currently on a preset value - simple state machine-like change
    %
    % Switch through preset rate multipliers
    % based on direction: +, 0, or -
    switch dir
        case '+'
            % Find multiplier in current list, lookup in incr/decr list
            newSpeedEnum = this.speedPresetIncr;
            this.speedPreset = newSpeedEnum(this.speedPreset == this.speedPresetCurr);
        case '-'
            newSpeedEnum = this.speedPresetDecr;
            this.speedPreset = newSpeedEnum(this.speedPreset == this.speedPresetCurr);
        otherwise % case '0', reset to 100% (full speed)
            this.speedPreset = 1.0;
    end
end

% Calculate new frame rate for caller
newFPS = this.speedPreset * this.Sourcefps;

% [EOF]
