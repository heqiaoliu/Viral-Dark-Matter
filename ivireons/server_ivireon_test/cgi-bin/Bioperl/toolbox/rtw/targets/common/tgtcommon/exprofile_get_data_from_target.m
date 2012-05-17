function profData = exprofile_get_data_from_target(connection, varargin)
%EXPROFILE_GET_DATA_FROM_TARGET retrieves profiling data from a target
%   
%   PROFDATA = EXPROFILE_GET_DATA_FROM_TARGET(CONNECTION) retrieves profiling
%   data PROFDATA from the TARGET using a CAN or Serial CONNECTION.
%
%   PROFDATA = EXPROFILE_GET_DATA_FROM_TARGET('Serial', 'BitRate', BITRATE)
%   uses the specified BITRATE.
%   
%   PROFDATA = PROFILE_C166('serial', 'CANChannel', CANCHANNEL) uses the
%   specified Vector Informatik CAN Application Channel, CANCHANNEL; CANCHANNEL
%   must be of the form 'MATLAB 1', 'MATLAB 2' etc.
%
%   PROFDATA = EXPROFILE_GET_DATA_FROM_TARGET(CONNECTION, 'SerialPort',
%   SERIALPORT) uses the specified SERIALPORT, which should be one of COM1,
%   COM2, etc.
%   

%   Copyright 1990-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2007/11/13 00:13:12 $

serial_port='COM1'; % default
bit_rate = [];
can_channel = 'MATLAB 1'; % default

for k=1:length(varargin)/2
    key = varargin{k*2-1};
    value = varargin{k*2};
    switch lower(key)
      
      case 'serialport'
        serial_port = value;
      
      case 'bitrate'
        bit_rate = value;
        
      case 'canchannel'
        can_channel = value;
        
      otherwise
        TargetCommon.ProductInfo.error('common', 'InvalidArgument', num2str(key));
        
    end
end

switch lower(connection)

  case 'can'

    if ~isempty(bit_rate)
      TargetCommon.ProductInfo.error('profiling', 'ProfilingInvalidArgBitrate');
    end

    
    first_data_timeout = 20;

    profData = exprofile_getdata_can(can_channel, ...
                                     first_data_timeout);

  case 'serial'

    if isempty(regexp(serial_port, 'COM[1-9][0-9]*'))
      TargetCommon.ProductInfo.error('profiling', 'ProfilingInvalidSerialPort', serial_port);
    end

    if ~isempty(bit_rate)
        serial_bit_rate = bit_rate;
    else
        serial_bit_rate = 57600;
    end
    local_check_bitrate(serial_bit_rate);
    
    first_data_timeout = 20;
    
    profData = exprofile_getdata_serial(serial_port, serial_bit_rate, first_data_timeout);

end

% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% does some basic check on the bit rate
function local_check_bitrate(bit_rate)

if (~(isscalar(bit_rate) && isa(bit_rate, 'double') && (bit_rate > 0)))
  TargetCommon.ProductInfo.error('profiling', 'ProfilingInvalidBitrate', num2str(bit_rate));
end

%end function local_check_bitrate
% -------------------------------------------------------------------------
