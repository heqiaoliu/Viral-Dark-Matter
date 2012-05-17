%MEMORYMAPPEDINFO_ASAP2 class representing a ASAP2 file
%   MEMORYMAPPEDINFO_ASAP2 class representing a ASAP2 file

%   Copyright 1990-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6.4.1 $  $Date: 2010/06/10 14:34:09 $

classdef MemoryMappedInfo_ASAP2 < handle

  properties(SetAccess = 'public', GetAccess = 'public')
    ASAP2File = '';
  end % properties(SetAccess = 'public', GetAccess = 'public')

  properties(SetAccess = 'private', GetAccess = 'private')
    tunableModelData;        
    measStructNames = {};
    measStructData = {};
    charStructNames = {};
    charStructData = {};
    sigStructNames = {};
    sigStructData = {};
    ASAP2FileExt = '.a2l';
    DAQListFile = '';
    DAQListFileName = 'DAQ_LIST_EVENT_MAPPINGS';
  end % properties(SetAccess = 'private', GetAccess = 'private')

  methods(Access = 'public')

    function this = MemoryMappedInfo_ASAP2(varargin)
      
      % Define constructors
      sigs{1} = {'tunableModelData'};
      sigs{2} = {'tunableModelData' 'ASAP2File'};

      % Parse arguments
      args = targets_parse_argument_pairs(sigs{end}, varargin);

      n = targets_find_signature(sigs, args);

      switch n
        % Constructor functions
        case 1
          % asap = MemoryMappedInfo_ASAP2('tunableModelData', td)
          this.tunableModelData = args.tunableModelData;
        case 2
          % asap = MemoryMappedInfo_ASAP2('tunableModelData', td, 'ASAP2File', 'C:\work\model.a2l')
          this.tunableModelData = args.tunableModelData;
          this.ASAP2File = args.ASAP2File;
        otherwise
          error('MemoryMappedInfo_ASAP2:Constructor', 'Unknown constructor, a recognized constructor signature was not found');
      end
    end % function MemoryMappedInfo_ASAP2
  end
  
   methods
    % This method sets the ASAP2File property which results in parsing of the 
    % new ASAP2 file and populates the tunableDataObject
    function set.ASAP2File(this, ASAP2File)
      % check the files exists
      existASAP2File = 2 == exist(ASAP2File);
      if ~existASAP2File
        error('MemoryMappedInfo_ASAP2:Property:ASAP2File:Invalid', '%s', ['The ASAP2 file ' ASAP2File ' does not exist.']);
      end
      % check the extension
      [pathstr, ~, ext] = fileparts(ASAP2File);
      correctExtension = strcmp(ext, this.ASAP2FileExt);
      if ~correctExtension
        error('MemoryMappedInfo_ASAP2:Property:ASAP2File:Extension', 'An ASAP2 file is expected to have the extension .a2l');
      end
      % check that the DAQ file exists
      DAQListFile = [pathstr '\' this.DAQListFileName];
      existDAQListFile = 2 == exist(DAQListFile);
      if ~existDAQListFile
        warning('MemoryMappedInfo_ASAP2:Property:DAQListFile:Invalid', 'A DAQ list event mappings file was not found.');
      end
      this.ASAP2File = ASAP2File;
      this.DAQListFile = DAQListFile;
      this.tunableModelData.clear();
      % do some processing of the file
      processASAP2File(this, existDAQListFile);
    end % function set.ASAP2File

    % This method sets the tunableModelData property
    function set.tunableModelData(this, tunableModelData)
      if isa(tunableModelData, 'TargetsMemoryMappedData_TunableModelData')
        this.tunableModelData = tunableModelData;
      else
        error('MemoryMappedInfo_ASAP2:Property:tunableModelData:Invalid', 'tunableModelData property must be a TargetsMemoryMappedData_TunableModelData object or a subclass of TargetsMemoryMappedData_TunableModelData');
      end
    end % function set.
   end

   methods(Access = 'public')
   
    % This method returns the address of a symbol in character form
    function address = getAddressString(this, symbol)
      address = {};
      
      member = false;
      [member, location] = ismember(this.measStructNames, symbol);
      idx = 1:length(this.measStructNames);
      required_idx = idx(location == 1);
      if length(required_idx) > 0
        address = this.measStructData(required_idx);
      end
      
      [member, location] = ismember(this.charStructNames, symbol);
      idx = 1:length(this.charStructNames);
      required_idx = idx(location == 1);
      if length(required_idx) > 0
        address = {address{:} this.charStructData{required_idx}};
      end
    end % function getAddressString
    
    % This method returns the address of a symbol in numeric form
    function address = getAddress(this, symbol)
      addressStr = this.getAddressString(symbol);
      address = {hex2dec(addressStr(:))'};
    end % function getAddressString
   
    % This method returns the symbol given its address
    function symbol = getSymbol(this, address)
      symbol = {};
      
      [member, location] = ismember(this.measStructData, address);
      idx = 1:length(this.measStructNames);
      required_idx = idx(location == 1);
      if length(required_idx) > 0
        symbol = this.measStructNames(required_idx);
      end
      
      [member, location] = ismember(this.charStructData, address);
      idx = 1:length(this.charStructNames);
      required_idx = idx(location == 1);
      if length(required_idx) > 0 
        symbol = {symbol{:} this.charStructNames{required_idx}};
      end
    end % function getSymbol
    
    % This method returns the event channel of a symbol
    function eventChannel = getEventChannel(this, symbol)
      eventChannel = {};
      [member, location] = ismember(this.sigStructNames, symbol);
      idx = 1:length(this.measStructNames);
      required_idx = idx(location == 1);
      if length(required_idx) > 0
        eventChannel = this.sigStructData(required_idx);
      end
    end % function getEventChannel
    
    % This method returns the number of event channels
    function numEventChannels = getNumEventChannels(this)
      eventChannels = unique(this.sigStructData);
      numEventChannels = length(eventChannels);
    end % function getNumEventChannels
    
    % This method prints out all the parameters
    function listParameters(this)
      for i=1:length(this.charStructNames)
        disp(this.charStructNames{i});
      end
    end % function listParameters
        
    % This method prints out all the signals
    function listSignals(this)
      for i=1:length(this.measStructNames)
        disp(this.measStructNames{i});
      end
    end % function listSignals

    % This method prints out all the DAQ signals
    function listDAQ(this)
      for i=1:length(this.sigStructNames)
        disp([this.sigStructNames{i} ' event channel ' this.sigStructData{i}]);
      end
    end % function listDAQ

  end % methods(Access = 'public')

  methods(Access = 'private')
    
    % This method handles the processing ASAP2 files and extract information into class data
    % structures
    function processASAP2File(this, existDAQListFile)
      parseASAP2File(this);
      if existDAQListFile
        parseDAQMappings(this);
      end
    end % function processASAP2File
    
    function parseASAP2File(this)

      fname = this.ASAP2File;
      input = fileread(fname);
      
      tokenmatches = regexp(input, 'begin MEAS.*?Name\s*\*\/\s*(\w*).*?ECU_ADDRESS\s*0x([0-9a-zA-Z]*)', 'tokens');
      disp('Searching ASAP2 file for signal information.')
      if isempty(tokenmatches)
        disp('No signal information was found in the ASAP2 file.');
      else
        if size(tokenmatches{1})~=[1 2]
          TargetCommon.ProductInfo.error('asap2', 'ASAP2FileFormattingSignal');
        end

        for i=1:length(tokenmatches)
          % Name of the measurement
          this.measStructNames(i) = { tokenmatches{i}{1} };
          % Address of the measurement
          this.measStructData(i) = { upper(tokenmatches{i}{2}) };
          % Create a Signal object add it to the TunableModelData object
          s = TargetsMemoryMappedData_Signal('symbolName', this.measStructNames{i}, 'address', this.measStructData{i});
          this.tunableModelData.addSymbol(s);
        end
      end

      tokenmatches = regexp(input, 'begin CHAR.*?Name\s*\*\/\s*(\w*).*?ECU Address\s*\*\/\s*0x([0-9a-zA-Z]*)', 'tokens');
      disp('Searching ASAP2 file for parameter information.')
      if isempty(tokenmatches)
        disp('No parameter information was found in the ASAP2 file.');
      else
        if size(tokenmatches{1})~=[1 2]
          TargetCommon.ProductInfo.error('asap2', 'ASAP2FileFormattingParameter');
        end

        for i=1:length(tokenmatches)
          % Name of the characteristic
          this.charStructNames(i) = { tokenmatches{i}{1} };
          % Address of the characteristic
          this.charStructData(i) = { upper(tokenmatches{i}{2}) };
          % Create a Parameter object add it to the TunableModelData object
          p = TargetsMemoryMappedData_Parameter('symbolName', this.charStructNames{i}, 'address', this.charStructData{i});
          this.tunableModelData.addSymbol(p);
        end
      end

    end % function parseASAP2File

    function parseDAQMappings(this)

      fname = this.DAQListFile;
      % parse the DAQ Mappings file for signals
      % return a struct of signal names and event channel numbers
      input = fileread(fname);

      tokenmatches = regexp(input, '(\w*):\s*Event Channel number = (\d*)', 'tokens');
      disp('Searching DAQ mapping file for DAQ event channel mappings.')
      if isempty(tokenmatches)
        disp('No DAQ event channel mappings were found in the DAQ mapping file.');
      else
        if size(tokenmatches{1})~=[1 2]
          TargetCommon.ProductInfo.error('asap2', 'DAQMappingFileFormatting');
        end

        for i=1:length(tokenmatches)
          this.sigStructNames(i) = { tokenmatches{i}{1} };
          this.sigStructData(i) = { tokenmatches{i}{2} };
          % Convert Signal object to DAQSignal objects based on event channel assignments
          sym = TargetsMemoryMappedData_Symbol('symbolName', this.sigStructNames{i});
          sig = this.tunableModelData.getSymbolsWithName(sym);
          this.tunableModelData.removeSymbol(sig{:});
          daqSig = TargetsComms_DAQSignal('signal', sig{:}, 'eventChannel', str2num(this.sigStructData{i}));
          this.tunableModelData.addSymbol(daqSig);
        end
      end
      
    end % function parseDAQMappings

  end % methods(SetAccess = 'private')

end % classdef
