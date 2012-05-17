function profData = exprofile_run(connection, varargin)
%EXPROFILE_RUN collects and displays execution profiling data from a target CPU
%    PROFDATA = EXPROFILE_RUN(CONNECTION) collects and displays execution
%    profiling data from a target microcontroller that is running a suitably
%    configured application. The CONNECTION must be set 'Serial' in order to
%    collect data via a Serial connection between the target and the host
%    computer. PROFDATA contains the execution profiling data in the format
%    documented by EXPROFILE_UNPACK.
%     
%    The data collected is unpacked then displayed in a summary HTML report and
%    as a MATLAB graphic. To configure a model for use with execution profiling,
%    the target must be running an execution profiling kernel with a driver to
%    upload data via a serial port. 
%
%    To use the serial connection, the target board must be connected via a
%    serial cable to one of the host computer's serial ports.  This function
%    defaults to port COM1 on the host computer. If the 'BitRate' argument is
%    not provided the default of 57600 baud will be used.
%
%    PROFDATA = EXPROFILE_RUN('serial', 'SerialPort', SERIALPORT) sets the serial
%    port to the specified SERIALPORT, which should be one of COM1, COM2, etc.
%     
%    PROFDATA = EXPROFILE_RUN('Serial', 'BitRate', BITRATE) sets the BITRATE
%    for serial connection to the target. BITRATE must be the same as the bit
%    rate specified for the application that is running on the target.
%
%    PROFDATA = EXPROFILE_RUN('Serial', 'ModelName', MODELNAME) automatically
%    sets the bit rate by analysing MODELNAME and extracting the serial
%    connection bit rate setting. MODELNAME should be set to the name of a model
%    which is currently open and is running on the target.
%
%    See also EXPROFILE_GET_DATA_FROM_TARGET, EXPROFILE_PROCESS_DATA,
%    EXPROFILE_UNPACK, EXPROFILE_GETDATA_CAN, EXPROFILE_GETDATA_SERIAL,
%    EXPROFILE_PLOT, EXPROFILE_REPORT

%   Copyright 2003-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/15 15:04:20 $

% Upload the execution profile data

if nargin==0 || ~any(strcmp(lower(connection),{'can','serial'}))
    % Print out a usage message to help the user
    error(sprintf([ mfilename ' requires you to specify a connection '...
                    'to the target board. Available connections '...
                    'are:\n' ...
                    '  ' mfilename '(''can'')\n' ...
                    '  ' mfilename '(''serial'')\n']));
end

rawdata = exprofile_get_data_from_target(connection, varargin{:});

if ~isempty(rawdata) % No data if time out occurred

    % Data uploaded from the target includes Task id information. Task ids 1, 2, 3,
    % are used to indicate periodic tasks, i.e. the base rate, sub-rate 1,
    % sub-rate 2 etc. Higher value task ids are used to represent non-periodic,
    % i.e. asynchronous tasks. Optionally, a task name may be assigned to the
    % asynchronous task ids; this name will be used in place of the task id in
    % the execution profile report. 
    profileInfo.tasks.names = {...
        'Interrupt 1'...
        'Interrupt 2'...
        'Interrupt 3'...
        'Interrupt 4'...
        'Interrupt 5'...
        'Interrupt 6'...
        'Interrupt 7'...
        'Interrupt 8'...
        'Interrupt 9'...
        'Interrupt 10'...
                   };
    profileInfo.tasks.ids = [ ...
        hex2dec('7FF0')...
        hex2dec('7FF1')...
        hex2dec('7F28')...
        hex2dec('7F29')...
        hex2dec('7F2A')...
        hex2dec('7F2B')...
        hex2dec('7F2C')...
        hex2dec('7F2D')...
        hex2dec('7F2E')...
        hex2dec('7F2F')...
                   ];

    % The raw data uploaded from the target has timer data in counter ticks, i.e. it
    % is uncalibrated; this value defines the base unit of time for converting
    % timer ticks to engineering units.
    profileInfo.timer.timePerTickUnits = 1e-9;
    
    % It is assumed that all counter values have size equal to the target processor
    % word size
    profileInfo.processor.wordsize = 2;
    
    % To decode the counter values the byte ordering on the target processor must be
    % defined
    profileInfo.processor.lsbFirst = 1;
    
    profData = exprofile_process_data(rawdata, profileInfo);
    
end

