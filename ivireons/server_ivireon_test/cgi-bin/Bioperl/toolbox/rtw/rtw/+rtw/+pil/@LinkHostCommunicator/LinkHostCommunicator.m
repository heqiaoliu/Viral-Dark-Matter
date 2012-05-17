classdef (Hidden = true) LinkHostCommunicator < rtw.connectivity.Communicator
%LINKHOSTCOMMUNICATOR communicates with a target application

%   Copyright 2008-2009 The MathWorks, Inc.

    % private properties
    properties (SetAccess = 'private', GetAccess = 'private')
        data_buffer_mem_units;
    end

    methods
        % constructor
        function this = LinkHostCommunicator(componentArgs, ...
                                             launcher)
            error(nargchk(2, 2, nargin, 'struct'));                                             
            % call super class constructor
            this@rtw.connectivity.Communicator(componentArgs, launcher);           
        end

        % Called to setup the communication channel to the target
        function initCommunications(this) %#ok<MANU>
            error(nargchk(1, 1, nargin, 'struct'));                                                         
        end

        % Called to shutdown the communication channel to the target
        function closeCommunications(this) %#ok<MANU>
            error(nargchk(1, 1, nargin, 'struct'));
        end

        % Called when a cosimulation run is started
        function startCommands(~)
            error(nargchk(1, 1, nargin, 'struct'));
        end

        % Called a when a cosimulation run is stopped / finished
        function endCommands(~)
            error(nargchk(1, 1, nargin, 'struct'));
        end

        % Called to send a command to the target
        function dataIn = processCommand(this, ...
                                         dataOut, ...
                                         dataInAmount, ...
                                         memUnitType)
            %PROCESSCOMMAND Handles generic Link I/O with the Link data 
            %               stream running on the target.
            %
            %   Arguments:
            %       dataOut     :    Data to transmit
            %       dataInAmount:    Amount of data to receive
            %       memUnitType :    Datatype of a memory unit
            %
            %   Return values:
            %       dataIn: PIL command result
                        
            dataToRead = dataInAmount;            
            
            if isempty(this.data_buffer_mem_units)
                % get buffer size from sub-class
                %
                % be careful to truncate the division to match the C implementation
                % of this division on the target (integer division truncates any fractional part)
                % note: both operands should be positive values                
                memUnitBytes = length(typecast(cast(1, memUnitType), 'uint8'));
                this.data_buffer_mem_units = floor(this.getDataBufferBytes / memUnitBytes);
            end
            
            BUFFER_SIZE = this.data_buffer_mem_units;
            
            dataToWrite = length(dataOut);
            dataindex = 1;
            
            if ~isempty(dataOut)
                initialReadAmount = min(BUFFER_SIZE, dataToRead);
                dataToRead = dataToRead - initialReadAmount;
            end
            
            % initially the target will be paused at the main breakpoint
            %
            % preallocate dataIn for speed
            dataIn = zeros(1, dataInAmount, memUnitType);
            while dataToWrite > 0
                transfer = min(BUFFER_SIZE, dataToWrite);
                sendData = dataOut(dataindex:dataindex+transfer-1);
                dataindex = dataindex+transfer;
                dataToWrite = dataToWrite - transfer;
                
                if (dataToWrite == 0) && (initialReadAmount > 0)
                    % no more data left after this => read first batch of output
                    % data
                    dataIn(1:initialReadAmount) = validatedLinkIO(this, sendData, initialReadAmount, memUnitType);
                else
                    this.linkIO(sendData, 0);
                end
            end
            
            % finish off any outstanding ydata
            dataInPtr = initialReadAmount + 1;
            while dataToRead > 0
                % assume target is writing in most efficient way possible
                % and only flushing when data is ready for transfer
                transfer = min(BUFFER_SIZE, dataToRead);
                dataInEndPtr = dataInPtr + transfer - 1;
                % make sure empty dataOut is of the correct memUnit type
                dataIn(dataInPtr:dataInEndPtr) = validatedLinkIO(this, cast([], memUnitType), transfer, memUnitType);
                dataToRead = dataToRead - transfer;
                dataInPtr = dataInEndPtr + 1;
            end            
        end                    
    end
    
    methods (Access = 'private')
        function dataIn = validatedLinkIO(this, dataOut, dataInAmount, memUnitType)
            dataIn = this.linkIO(dataOut, dataInAmount);
            dataInClass = class(dataIn);
            % check dataIn is of the correct memory unit type
            if ~strcmp(dataInClass, memUnitType)
                rtw.pil.ProductInfo.error('pilverification', 'InvalidTypeDataIn', memUnitType, dataInClass);
            end
            % check dataIn is of the correct length
            if length(dataIn) ~= dataInAmount
                rtw.pil.ProductInfo.error('pilverification', 'InvalidSizeDataIn', int2str(dataInAmount), int2str(length(dataIn)));
            end
        end
    end
    
    % abstract methods
    methods (Abstract = true)        
        dataIn = linkIO(this, dataOut, dataInAmount)
        %LINKIO Link specific I/O implementation for PIL
        %
        %   Arguments:
        %     dataOut - Array of memory units to send to the target
        %     dataInAmount - Number of memory units to read from the target after writing "dataOut"
        %
        %   Return values:
        %      dataIn - The "dataInAmount" memory units read from the target.
        %      
        
        bufferBytes = getDataBufferBytes(this)
        % GETDATABUFFERBYTES: Returns the number of bytes in the stream data buffer
        %
        % bufferBytes = getDataBufferBytes
        %
    end
end
