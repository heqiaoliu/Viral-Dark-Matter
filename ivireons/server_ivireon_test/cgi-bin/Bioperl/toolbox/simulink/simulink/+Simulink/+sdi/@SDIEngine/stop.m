function stop(this)

    % Stop recording
    %
    % Copyright 2009-2010 The MathWorks, Inc.

    % Clear the list
    Simulink.sdi.Instance.record(false);

    % Set recording status to off
    this.RecordStatus = false;
end