function profData = exprofile_getdata_can(chan, first_data_timeout)
%EXPROFILE_GETDATA_CAN retrieves execution profiling data via CAN
%   EXPROFILE_GETDATA_CAN(CHANNEL, FIRST_DATA_TIMEOUT) requests execution
%   profiling data by sending a message over CAN and then uploads the returned
%   data. CHANNEL is a the Vector Informatik CAN Application channel; it must be
%   a string of the form 'MATLAB 1', 'MATLAB 2' etc. FIRST_DATA_TIMEOUT is the
%   length of time, in seconds, to wait for the first message containg data to
%   be returned from the target processor.

%   Copyright 1994-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $
  
% Hard-coded CAN message identifiers
  command_id = hex2dec('1FFFFF00');
  data_id_std = [];
  data_id_xtd = hex2dec('1FFFFF01');
  
  % Get the channel number
  t = regexp(chan,'MATLAB ([1-9][0-9]*)','tokens');
  if isempty(t)
    TargetCommon.ProductInfo.error('profiling', 'ProfilingCANInvalidChannel', num2str(chan));
  end
  chNum = str2num(t{1}{1});
  chNum = chNum-1; % change from 1-based to zero-based.
  
  % Utilities for sending and receiving CAN messages
  import('com.mathworks.toolbox.ecoder.canlib.vector.*');
    
  % Create an application channel
  channel = VectorChannel(chNum);
  
  % Create a write port
  try
      masterPort = channel.createMasterPort('exprofile_master');
  catch e %#ok<NASGU>
    TargetCommon.ProductInfo.error('profiling', 'ProfilingCANInvalidConnection');
  end
  % Create a read port
  readPort = channel.createReadPort(masterPort, data_id_std, data_id_xtd, 'data_reader');
  
  % Transmit a start command message
  frame = CAN_FRAME.createXtd(command_id);
  command_data = 1;
  frame.setDATA(command_data);
  try 
      masterPort.sendData(frame);
  catch e
    disp(e.message);
    i_shutdown(readPort, masterPort);
    TargetCommon.ProductInfo.error('profiling', 'ProfilingCANStartFailed', num2str(chan));    
  end

  disp(' ')
  disp(['Sent CAN message with identifier 0x' dec2hex(command_id) ' to request '...
        'upload of execution profiling data.']);
  disp(' ')
  disp(['Waiting to receive CAN message, identifier 0x' ...
        dec2hex(data_id_xtd) dec2hex(data_id_std) ', containing execution profiling '...
        'data ...'])

  % Initialize a CAN frame to hold the read data
  frame = CAN_FRAME.createXtd(1);
  timestamp = 0;
  
  % Initialize return value from readData to indicate no message received
  rx = -1;
  
  % Note the start time
  tic
  ttoc = 0;
  
  timeout = first_data_timeout;
  first_data_received = 0;
  profData = [];
  
  while ttoc < timeout
    
    if rx >= 0 
      if first_data_received == 0
        first_data_received = 1;
        disp(' ')
        disp('Received first CAN message with execution profiling data.')
        disp(' ')
        disp('Uploading data, please wait ...')
        disp(' ')
      end
      timeout = ttoc + 4;
      profData = [profData; double(data)];
    end
    
    try 
        % Return value is >= 0 if message received or -1 if no message received
        rx = readPort.readData(frame, timestamp);
        data = frame.getDATA;
    catch e
        disp(e.message);
        i_shutdown(readPort, masterPort);
        TargetCommon.ProductInfo.error('profiling', 'ProfilingCANMessageRX');
    end      
    
    % Make toc robust against intermittent failure 335195
    newtoc = toc;
    if newtoc > 8e9 % is it a bad value
        for i=1:1e7
            newtoc = toc;
            if newtoc < 8e9 % is it a good value
                break
            end
        end
    end
    ttoc = ttoc + newtoc;
    tic
      
  end
  
  i_shutdown(readPort, masterPort);
    
  if isempty(profData)
    disp(sprintf([...
        'Timeout occurred. No execution profiling data was received from '...
        'the target. You should check the following:\n\n'...
        '   1. The CAN port on the target is connected to the CAN port on the '...
        'host machine.\n'...
        '   2. The application on the target is running.\n'...
        '   3. The application on the target is properly configured to '...
        'provide execution profiling data.\n'...
        '   4. The application on the target and the host CAN channel are '...
        'configured to use the same bit rate. To check the bit rate on '...
        'the target, you must inspect your model and review the settings '...
        'for the CAN channel used by execution profiling. To check the bit '...
        'rate on the host, you must run the Vector Informatik configuration '...
        'utility and inspect the Baudrate settings for the Application Channel '...
        'used by this execution profiling command; to run this utility, type '...
        'vcanconf from a Windows command prompt. '...
        ' \n\n'...
        'If you are performing execution profiling over a long period of time '...
        'it may be necessary to increase the timeout value.']));
  end
  
  % Return the data as a column vector
  profData = profData';
  profData = profData(:);
  
  
  function i_shutdown(readPort, masterPort)
    if ~isempty(readPort)
        readPort.ShutdownPort;
    end
    if ~isempty(masterPort)
        masterPort.ShutdownPort;
    end
    
