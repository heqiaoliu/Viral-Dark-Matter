classdef Stream < handle
% An abstract class that implements functionality common to all streams.

% Authors: DTL
% Copyright 2007-2010 The MathWorks, Inc.
% $Revision: 1.1.6.6 $

    properties(GetAccess='public',SetAccess='private')
        % The dimension of the stream's data that indicates the item count.
        CountDimension = 1;
    end
    
    properties(GetAccess='public',SetAccess='public')
        % The timeout value, in seconds, used by all blocking calls that
        % are implemented using the wait method. 
        Timeout = 10.0;
    end
        
    methods(Access='public')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Lifetime
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function obj = Stream(channelImpl)
        % STREAM Create a wrapper for a channel's stream.
          
        % OBJ = STREAM(CHANNELIMPL) creates an object that wraps the
        % actual underlying C++ stream implementation. 
        %
            assert(nargin == 1, 'Stream:Stream:invalidArgumentCount',...
                                'Invalid number of arguments');

            % Get the class of this object without the package.
            className = class(obj);
            dots = strfind(className,'.');
            className = className(dots(end)+1:end);

            % Create underlying implementation.
            obj.StreamImpl = asyncioimpl.(className)(channelImpl);
            
            % Optimization: cache constant value - 30% speedup.
            if isSupported(obj)
                obj.CountDimension = obj.StreamImpl.getCountDimension();
            end
        end  
        
        function delete(obj)
        % DELETE Destroy the wrapper of the stream.
           
            % Delete underlying implementation.
            delete(obj.StreamImpl);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Getters/Setters
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
        
        function result = isSupported(obj)
        % ISSUPPORTED Return true if the device supports this stream.
        %
        % RESULT = ISSUPPORTED(OBJ) returns true if the device supports
        % this stream and returns false otherwise. If false, all other 
        % methods of OBJ will result in an error.
            result = obj.StreamImpl.isSupported();
        end
        
        function result = isDeviceDone(obj)
        % ISDEVICEDONE Return true if the device is done.
        %
        % RESULT = ISDEVICEDONE(OBJ) returns true if the device is "done".
        % For input, done may indicate that the end of file has been 
        % reached and no more data will be written to the stream. For
        % output, done may indicate there is no longer any space available
        % on the device. 
            result = obj.StreamImpl.isDeviceDone();
         end
         
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Commands
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
        
        function flush(obj)
        % FLUSH Flush all data in the stream.
        %
        % FLUSH(OBJ) immediately discards all data in the stream.
                             
            % Discard anything in the stream.
            obj.StreamImpl.flush();
        end
    end

         
    methods(Access='protected')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Getters/Setters
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function result = isOpen(obj)
        % ISOPEN Return true if the stream is open, false otherwise..
            result = obj.StreamImpl.isOpen();
        end
        
        function count = getSpaceAvailable(obj)
        % GETSPACEAVAILABLE Get the amount of space available in the stream.
        % If the stream has no size limit, Inf is returned.
            count = obj.StreamImpl.getSpaceAvailable();
        end

        function count = getDataAvailable(obj)
        % GETDATAAVAILABLE Get the amount of data available in the stream.
            count = obj.StreamImpl.getDataAvailable();
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Commands
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function status = wait(obj, completedFcn)
        % WAIT Wait until the completion function returns true or the
        % stream is "done" or an error occurs.

            % Initialize return value.
            status = '';
            
            % Initialize internal values.
            invalid = false;            
            timeout = false;
            done = false;            
            completed = completedFcn(obj);
            startTime = clock;                        
            % NOTE: Order is important. Completed has priority over 
            % done and timeout.
            while ~completed && ~done && ~timeout
                % NOTE: We can not catch CTRL-C here. See geck 276016.
                pause(0.01);
                % NOTE: To work around geck 572544, do drawnow to force
                % callbacks to happen on UNIX.
                if isunix
                    drawnow;
                end

                if ~isvalid(obj)
                    invalid = true;
                    break; % Must break immediately.
                end
                
                timeout = (etime(clock,startTime) > obj.Timeout);
                done = obj.isDeviceDone() || ~obj.isOpen();
                completed = completedFcn(obj);
            end
            
            % Set error string based on the loop exit condition.
            if invalid 
                status = 'invalid';
            elseif completed
                status = 'completed';
            elseif done 
                status = 'done';
            elseif timeout
                status = 'timeout';
            end
        end
    end
    
    methods(Access='protected',Static=true)
       
        function packets = splitPacket(packet, countDimension, sizes)
        % SPLITPACKET Split a PACKET into a cell array of packets.
        % 
        % PACKETS = SPLITPACKET(PACKET, COUNTDIMENSION, SIZES) splits a
        % single matrix into a cell array of matrices that have the
        % given sizes along the count dimension. The inverse of 
        % PACKET = CAT(COUNTDIMENSION, PACKETS{:})
        % 
        % Inputs:
        % PACKET - The N-dimensional matrix to split.
        % COUNTDIMENSION - The dimension of packet that indicates the count.
        %    From 1 to ndims(packet).
        % SIZES - A matrix that indicates the length of each packet.
        %    The elements of SIZES must sum to the length of the count
        %    dimension of packet.
        %
        % Outputs:
        % PACKETS - A cell array containing the resulting packets.
        %
        
            % Initialize output.
            packets = cell(1,length(sizes));
        
            % Optimization: Use colon operator for 2-D arrays - 300%
            % speedup over N-D case.
            if ndims(packet) == 2 
                start = 1;
                for ii=1:length(sizes)
                    if countDimension == 1
                        packets{ii} = packet(start:start+sizes(ii)-1,:);
                    else
                        packets{ii} = packet(:,start:start+sizes(ii)-1);
                    end
                    start = start + sizes(ii);
                end
            % Otherwise handle N-D case. 
            % Optimization: Don't use mat2cell - 200% speedup.
            else
                % Create a cell array of indices for every dimension but
                % the count dimension.
                dims = cell(1,ndims(packet));
                for ii=1:length(dims)
                    if ii == countDimension
                        dims{ii} = 0;
                    else
                        dims{ii} = 1:size(packet,ii);
                    end
                end
                
                % Vary the indices for the count dimension as we
                % index into the input matrix to get each sub-matrix.
                start = 1;
                for ii=1:length(sizes)
                    dims{countDimension} = start:start+sizes(ii)-1;
                    packets{ii} = packet(dims{:});
                    start = start + sizes(ii);
                end
            end
        end
    end
        
    methods
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Property Access Methods
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
        function set.Timeout(obj, timeValue)
            assert(isscalar(timeValue) && isfloat(timeValue) &&...
                   timeValue >= 0.0,...
                   'Stream:timeout:invalidTime',...
                   'TIMEVALUE must be a non-negative scalar double');
            obj.Timeout = timeValue;
        end
    end
    
    properties(GetAccess='protected',SetAccess='private')
        % Underlying C++ implementation.
        StreamImpl;
    end  
end

