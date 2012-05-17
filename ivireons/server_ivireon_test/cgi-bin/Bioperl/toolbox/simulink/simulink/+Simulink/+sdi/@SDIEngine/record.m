function record(this)

    % RECORD creates a run every time a simulink model gets executed.
    % To stop recording call the "stop" method.
    %
    % Copyright 2009-2010 The MathWorks, Inc.

    % Check if its already recording
    if ~this.isRecording()
        Simulink.sdi.Instance.record(true);

        % Set recording status on
        this.RecordStatus = true;
    end % if
end