%TARGETSCOMMS_EXTERNALMODECCP class used for External Mode CCP communications
%   TARGETSCOMMS_EXTERNALMODECCP class used for External Mode CCP communications

%   Copyright 1990-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2008/05/01 20:23:05 $

classdef TargetsComms_ExternalModeCCP < handle

  properties(GetAccess = 'protected', SetAccess = 'protected')
    ccpMaster;
    % Endian
    % BIG ENDIAN = 1, LITTLE ENDIAN = 0
    targetEndian;
    CANIdCRO = 1786;
    CANIdDTO = 1787;
    messageType = com.mathworks.toolbox.ecoder.canlib.vector.VectorCAN.CAN_MESSAGE_EXTENDED;
    % Application channels
    % 0 = MATLAB 1
    % 1 = MATLAB 2
    applicationChannel = 0;
    % Default values
    addressExtension = 0;
    mta = 0;
    % there are n odt in blk but depending on event channels this maybe <
    % or == to the number on the target
    numODTs;
    lastEventChannel;
  end % properties(GetAccess = 'protected', SetAccess = 'protected')

  properties(GetAccess = 'private', SetAccess = 'private')
    connected = false;    
    DAQRunning = false;
    numAvailableODTs;
    numEventChannels;
    lastODT;
    % contains the mapping between signal addresses and odts where the odt number 
    % is the index
    ODT_to_Address_mapping = {};
    ODT_to_Size_mapping = {};
    DAQ_to_EventChannel_Mapping = [];
    DAQData;
    hardwareAvailable;
  end
  
  methods
    
    function this = TargetsComms_ExternalModeCCP(varargin)
      % Define constructors
      sigs{1} = {'numEventChannels'};

      % Parse arguments
      args = targets_parse_argument_pairs(sigs{end}, varargin);

      n = targets_find_signature(sigs, args);
      
      switch n
        case 1
          this.numEventChannels = args.numEventChannels;
          this.DAQData = TargetsUtils_Bins();
          % Is hardware available
          this.hardwareAvailable = true;
        otherwise
          error('TargetsComms_ExternalModeCCP:Constructor', 'Unknown constructor, a recognised constructor signature was not found');
      end
      
    end % function TargetsComms_ExternalModeCCP
    
    function success = connect(this)
      success = false;
      try
        if this.hardwareAvailable
          this.ccpMaster.sendCONNECT(1);
        end
        this.connected = true;
        success = true;
      catch eObj
        % shutdown nicely.
        if this.hardwareAvailable
          if ~isempty(this.ccpMaster)
            this.ccpMaster.close();
          end
        end
        error('TargetsComms_ExternalModeCCP:connect', [sprintf('\n') 'It was not' ...
          ' possible to connect to the target using CCP. An error occurred' ...
          ' when issuing the CONNECT command:' sprintf('\n\n') eObj.message]);
      end
    end % function connect

    function disconnect(this)
      if this.connected
        this.connected = false;
        if this.hardwareAvailable
          this.ccpMaster.close();
        end
        this.delete()
      end
    end % function disconnect

    function transmitParameterUpdate(this, address, value)
      if this.hardwareAvailable
        this.ccpMaster.sendSET_MTA(this.mta, this.addressExtension, address);
        this.ccpMaster.sendDNLOAD(value);
      end
    end % function transmitParameterUpdate

    function setupDAQSignal(this, address, dataTypeSize, eventChannel)
      % Default values
      % we only use 1 element of the odt - to avoid complex unpacking
      odtElement = 0;
      prescaler = 1;
      prepmode = 2;
      
      % Set the DAQ list
      % Have we seen this eventChannel before
      member = ismember(this.DAQ_to_EventChannel_Mapping, eventChannel);
      if any(member)
        % This eventChannel has been seen before - find it in the mapping list
        daq_ids = 0:(length(this.DAQ_to_EventChannel_Mapping) - 1);
        daq_id = daq_ids(member == 1);
      else
        % This eventChannel has not been seen before - add it to the mapping list
        this.DAQ_to_EventChannel_Mapping(end + 1) = eventChannel;
        % DAQ list is 0 indexed
        daq_id = length(this.DAQ_to_EventChannel_Mapping) - 1;
      end

      % Check if we have run out of ODTs for this DAQ
      if (this.numAvailableODTs(daq_id + 1) < 1)
        error('TargetsComms_ExternalModeCCP:setupDAQSignal', 'Not enough ODTs available');
      else
        % Set ODT
        odt = this.lastODT - (this.numAvailableODTs(daq_id + 1) - 1);
        % Reduce the number of available ODTs on this DAQ
        this.numAvailableODTs(daq_id + 1) = this.numAvailableODTs(daq_id + 1) - 1;

        % Setup some mappings for when we read back the data
        % Calculate the PID
        odtIdx = ((daq_id * this.lastODT) + (daq_id * 1)) + odt;
        % Setup the mappings
        this.ODT_to_Address_mapping(odtIdx + 1) = { address };
        this.ODT_to_Size_mapping(odtIdx + 1) = { dataTypeSize };

        if this.hardwareAvailable
          % Send the CCP commands
          this.ccpMaster.sendSET_DAQ_PTR(daq_id, odt, odtElement);
          this.ccpMaster.sendWRITE_DAQ(dataTypeSize, this.addressExtension, address);
          this.ccpMaster.sendSTART_STOP(prepmode, daq_id, odt, eventChannel, prescaler);
        end
      end
    end
    
    function startDAQ(this)
      this.DAQRunning = true;
      if this.hardwareAvailable
        this.ccpMaster.sendSTART_STOP_ALL(1);
      end
    end
    
    function stopDAQ(this)
      if this.DAQRunning
        if this.hardwareAvailable
          this.ccpMaster.sendSTART_STOP_ALL(0);
        end
        lastsDAQList = length(this.DAQ_to_EventChannel_Mapping) - 1;
        % Clear existing DAQ lists
        for DAQlist=0:lastsDAQList
          if this.hardwareAvailable
            this.ccpMaster.sendGET_DAQ_SIZE(DAQlist, this.CANIdDTO);
          end
        end        
        % Reinitialise
        this.ODT_to_Address_mapping = {};
        this.ODT_to_Size_mapping = {};
        this.DAQ_to_EventChannel_Mapping = [];
        this.numAvailableODTs = repmat(floor(this.numODTs / (this.numEventChannels)), 1, (this.numEventChannels));
      end
    end
    
    function data = getDAQData(this, address)
      % The size of the host side CAN hardware buffer is 1024 so we will read at most this number of messages
      bufferSize = 1024;
      
      % Process messages
      for i=1:bufferSize
        msg = [];
        if this.hardwareAvailable
          msg = this.ccpMaster.readDAQ;
        end
        if isempty(msg)
          break;
        else
          % Process the msg
          odt = msg.getODT_ID;
          odtIdx = odt + 1;          
          msgData = msg.getDataUnsigned;
          msgData = msgData';
          % Trim the data to the right size
          msgData = msgData(1:this.ODT_to_Size_mapping{odtIdx});          
          addressId = this.ODT_to_Address_mapping{odtIdx};
          if isempty(msgData) && isempty(addressId)
            error('TargetsComms_ExternalModeCCP:getDAQData', [sprintf('\n') 'The number' ...
              ' of ODTs specified has changed since the last build, no address' ...
              ' or size mapping data is available for this ODT. Please rebuild and' ...
              ' re-download the model before connecting to external mode.']);
          end
          this.DAQData.addElement(addressId, msgData);
        end % if
      end % for

      % Get the data for this address
      address = hex2dec(address);
      data = this.DAQData.getBin(address);
      % Clear the data for this address
      this.DAQData.clearBin(address);
    end
    
    function applicationChannel = get.applicationChannel(this)
      applicationChannel = this.getApplicationChannel();
    end
    
    function targetEndian = get.targetEndian(this)
      targetEndian = this.getTargetEndian();
    end
    
  end % methods
  
  methods(Access = 'protected')
    
    function initialise(this)
      if this.hardwareAvailable
        import('com.mathworks.toolbox.ecoder.canlib.ccp.*');
        import('com.mathworks.toolbox.ecoder.canlib.ccp.vectorcan.*');
        import('com.mathworks.toolbox.ecoder.canlib.vector.*');

        % Application channel setup
        channel = VectorChannel(this.applicationChannel);       
      end
      
      try
        if this.hardwareAvailable
          % Create a CAN CCP network node
          netnode = VectorCCPNetworkNode(channel, this.CANIdCRO, this.CANIdDTO, this.messageType);
        end
      catch e
        result = regexp(e.message, 'ID String is already in the map', 'once');
        if ~isempty(result)
          error('TargetsComms_ExternalModeCCP:initialise', [sprintf('\n') 'An error occurred' ...
            ' when trying to connect to the target. This is because a previous' ...
            ' connection with the target was not closed correctly. To resolve' ...
            ' this error it is necessary to restart MATLAB.']);
        else
          % A different connection related error occurred
          rethrow(e);
        end
      end

      if this.hardwareAvailable
        % Create CCPMaster
        this.ccpMaster = CCPMaster(netnode, this.targetEndian);
        this.connected = true;
        this.ccpMaster.setCROTimeout(5000);
      end

      % Maybe this should be a user function - so that users can provide their own mapping
      this.numAvailableODTs = repmat(floor(this.numODTs / (this.numEventChannels)), 1, (this.numEventChannels));
      this.lastODT = floor(this.numODTs / (this.numEventChannels)) - 1;
    end

    function applicationChannel = getApplicationChannel(this) %#ok<STOUT>
      error('TargetsComms_ExternalModeCCP:getApplicationChannel', 'getApplicationChannel function should be overloaded in a subclass');
    end

    function targetEndian = getTargetEndian(this) %#ok<STOUT>
      error('TargetsComms_ExternalModeCCP:getTargetEndian', 'getTargetEndian function should be overloaded in a subclass');
    end

  end % methods(Access = 'protected')
	
end % classdef
