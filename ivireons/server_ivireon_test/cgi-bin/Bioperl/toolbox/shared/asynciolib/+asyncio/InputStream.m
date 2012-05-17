classdef InputStream < asyncio.Stream
% A stream that asynchronously reads from a device and buffers incoming data.
%
%   If the device supports input, then isSupported() will return true and
%   data can be read from the stream.
%
%   See also asyncio.OutputStream and asyncio.Channel.

% Authors: DTL
% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $

    properties(GetAccess='public',SetAccess='private',Dependent=true)
        % The number of items that can be read without blocking.
        DataAvailable; 
    end
    
    events(NotifyAccess='public')
        % Device has written data to the input stream and data is available
        % to read. The data associated with this event is an 
        % asyncio.DataEventInfo where CurrentCount is the amount of data 
        % available to read.
        DataWritten  
    end
    
    methods(Access='public')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Lifetime
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function obj = InputStream(channelImpl)
        % INPUTSTREAM Create a wrapper for a channel's input stream.
          
        % OBJ = INPUTSTREAM(CHANNELIMPL) creates an object that wraps the
        % actual input stream of CHANNELIMPL. 
        %
        % Notes:
        % If the channel has no input stream, then isSupported will return
        % false and no other methods will succeed.
            assert(nargin == 1, 'The parent channel was not specified');
           
            % Construct super class.
            obj@asyncio.Stream( channelImpl );
            
            % Initialize partial packet used by read.
            obj.PartialPacket = [];
        end  
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Commands
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
        
        function [data, countRead, err] = read(obj, countRequested)
        %READ Read data from the input stream.  
        %
        % [DATA, COUNTREAD] = READ(OBJ, COUNTREQUESTED)
        % reads the requested number of items from the input stream. If the
        % count requested is less than DataAvailable then this method will
        % block. If blocking is needed, read will wait until the requested 
        % number of items are read or the channel is closed or the device 
        % is done reading data or an error occurs.
        %
        % Inputs:
        % COUNTREQUESTED - Indicates the number of items to read. This 
        %     parameter is optional and defaults to all the data currently
        %     available on the input stream. 
        %
        % Outputs:
        % DATA - An N-dimensional matrix of data. The dimension that 
        %     indicates the count is specified by the CountDimension property.
        %     If no data was returned this will be an empty array.
        %
        % COUNTREAD - The actual number of items read. If there was no error,
        %     this value will be equal to the count requested unless the 
        %     channel was closed or the device was done. If there was an
        %     error, this value will be zero.
        %
        % ERR - A string that indicates if any error occurred while
        %     waiting for data to arrive. Possible values are:
        %       'timeout' -   The timeout elapsed.
        %       'invalid' - The channel or stream was deleted.
        %       '' - No error occurred.
        
            % If countRequested not specified...
            if nargin < 2
                % Read what is available.
                countRequested = obj.DataAvailable;
            % Otherwise, validate it.
            elseif ~(isnumeric(countRequested) && isscalar(countRequested) && ...
                     countRequested >= 0)
                error('InputStream:read:invalidCountRequested',...
                      'COUNTREQUESTED must be a non-negative scalar numeric value'); 
            end
 
            % Initialize return values.
            data = [];
            countRead = 0;
            err = '';
            
            % Initialize internal values.
            packetsRead = {};
            countDimension = obj.CountDimension;
            
            % If there is a partial packet remaining from the previous
            % read, start with that.
            if ~isempty(obj.PartialPacket)
                packetsRead = {obj.PartialPacket};
                countRead = size(obj.PartialPacket, countDimension);
                
                % Clear the partial packet.
                obj.PartialPacket = [];
            end
            
            % While we need more data to satisfy request.
            while countRead < countRequested
               
                % Optimization: Don't call wait unless needed and use
                % underlying stream directly - 15% speedup.
                if obj.StreamImpl.getDataAvailable() == 0
                    
                    % Wait for any data to be available on the stream.    
                    status = obj.wait(@(obj) obj.getDataAvailable() > 0);
                
                    % If no data was available, break.
                    if ~strcmpi(status, 'completed')
                        % Set error value.
                        err = status;                    

                        % If object became invalid, return immediately.
                        if strcmpi(status, 'invalid')
                            return;
                        end

                        % Don't consider done an error.
                        if strcmpi(status, 'done') 
                            err = '';
                        end
                        break;
                    end
                end
                
                % Try to read what we need.
                countToRead = countRequested - countRead; 

                % Get a cell array of data packets that satisfies
                % as much of our request that is available.
                [packets, count] = obj.readPackets(countToRead);
                
                % Accumulate the packets and the count.
                packetsRead = [packetsRead packets]; %#ok<AGROW>
                countRead = countRead + count;
            end
           
            % Check if we've gotton too much.
            if ( countRead > countRequested )
                
                % Determine how much of the last packet is needed,
                % and how much is extra.
                packetExtra = packetsRead{end};
                countExtra = countRead - countRequested;
                countNeeded = size(packetExtra, countDimension) - countExtra;
                
                % Break the packet along the count dimension into arrays 
                % that contain the needed and extra data.
                splitPackets = asyncio.Stream.splitPacket(packetExtra, ...
                                    countDimension, [countNeeded, countExtra]);
                
                % Use the needed packet and save the extra for the next read.
                packetsRead{end} = splitPackets{1};
                obj.PartialPacket = splitPackets{2};
            end
            
            % Concatentate cell array into a single matrix along the 
            % count dimension.
            data = cat(countDimension, packetsRead{:});
            if ~isempty(data)
                countRead = size(data, countDimension);
            else
                countRead = 0;
            end
            
            % If there was an error, don't return any data, 
            % but save it for any subseqent reads.
            if ~isempty(err)
               obj.PartialPacket = data;
               data = [];
               countRead = 0;
            end
        end

        function [packets, countRead] = readPackets(obj, countRequested)
        %READPACKETS Read a cell array of data packets from the input stream.  
        %
        % [PACKETS, COUNTREAD] = READPACKETS(OBJ, COUNTREQUESTED)
        % reads a cell array of data packets from the input stream that 
        % satisfies as much of our request as is available. This method does 
        % not block.
        %
        % Inputs:
        % COUNTREQUESTED - Indicates the desired number of items to read.
        %
        % Outputs:
        % PACKETS - A 1xN cell array of data packets. 
        %
        % COUNTREAD - The actual number of items read. This may be less than
        %     the number requested if enough data is not available in the
        %     input stream. It also may be more than the number requested
        %     if the count requested is not an even multiple of the packet
        %     size.
            [packets, countRead] = obj.StreamImpl.read(countRequested);
        end
        
        function flush(obj)
        % FLUSH Flush all data in the stream.
        %
        % FLUSH(OBJ) immediately discards all data in the stream.
        
            % Clear any partial packet left over from the last read.
            obj.PartialPacket = [];
        
            % Call superclass to discard anything in the stream.
            flush@asyncio.Stream(obj);
        end
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Property Access Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function count = get.DataAvailable(obj)
            % Start with any partial packet left over from the last read.
            if ~isempty(obj.PartialPacket)
                count = size(obj.PartialPacket, obj.CountDimension);
            else
                count = 0;
            end

            % Add data available in the stream.
            count = count + obj.getDataAvailable();
        end
    end
       
    properties(GetAccess='private',SetAccess='private')
        % Holds any extra items from the last read.
        PartialPacket;
    end    
end

