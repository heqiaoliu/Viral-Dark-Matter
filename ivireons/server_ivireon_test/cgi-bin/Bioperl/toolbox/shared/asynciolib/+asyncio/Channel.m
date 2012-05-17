classdef Channel < dynamicprops
% A communications channel to any device that is a data source or sink. 
% 
%   The device may be a piece of hardware, a file, socket, network, etc. 
%   The device may be bidirectional, input-only, or output-only. If the device
%   is a source of incoming data, then the channel will contain a valid 
%   InputStream property. If the device is a sink for outgoing data, then the 
%   channel will contain a valid OutputStream property.
% 
%   The channel works in conjunction with a two C++ plug-ins. The device
%   plug-in wraps the device-specific software API. The converter plug-in
%   converts data in MATLAB format to a format expected by the device
%   plug-in (and vica-versa).
%
%   See also asyncio.Channel.Channel, asyncio.InputStream, asyncio.OutputStream.

% Authors: DTL
% Copyright 2007-2010 The MathWorks, Inc.
% $Revision: 1.1.6.6 $

    properties(GetAccess='public',SetAccess='private')
        % An asyncio.InputStream used for reading.
        InputStream;        
        
        % An asyncio.OutputStream used for writing.
        OutputStream;       
    end
    
    events(NotifyAccess='private')
        % The channel has been closed.
        Closed
        
        % The channel has been opened.
        Opened

        % A device-specific custom event has occurred.
        Custom              
    end
    
    methods(Access='public')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Lifetime
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function obj = Channel(devicePluginPath, converterPluginPath, ...
                               options, streamLimits)
        % CHANNEL Create an asynchronous communication channel to a device.
        %
        % OBJ = CHANNEL(DEVICEPLUGINPATH, CONVERTERPLUGINPATH, 
        %               OPTIONS, STREAMLIMITS)
        % creates a communication channel to the given device and sets up 
        % the appropriate input and output streams. 
        %
        % Inputs:
        % DEVICEPLUGINPATH - The full path and name of the device plug-in.
        % The file extension of the plug-in should be omitted.
        %
        % CONVERTERPLUGINPATH - The full path and name of the converter
        % plug-in. The file extension of the plug-in should be omitted.
        %
        % OPTIONS - A structure containing information that needs to be 
        % passed to the device plug-in during initialization. This parameter 
        % is optional unless STREAMLIMITS also needs to be specified. 
        % The default value for this parameter is an empty structure.
        %
        % STREAMLIMITS - An array of two doubles that indicate the maximum 
        % number of items to buffer in the input and output streams. Valid
        % values for each limit are between 0 and Inf, inclusive. If Inf is
        % used, buffering will be limited only by the amount of memory available 
        % to the application. If zero is used, the stream is unbuffered and all
        % reads or writes are synchronous (i.e go directly to the device). 
        % This parameter is optional. The default value for this parameter 
        % is [Inf Inf]. 
        %
        % Notes:
        % During initialization, the device plug-in can specifiy custom
        % properties and their initial values. These properties will be
        % created as dynamic properties on the channel object and can be 
        % updated at any time by the device plug-in.
            
            % If no stream limits specified, provide a default.
            if nargin < 4
                streamLimits = [Inf Inf];
            end

            % If no options specified, provide a default.
            if nargin < 3 || isempty(options)
                options = struct([]);
            end
            
            assert( isfloat(streamLimits) && length(streamLimits) == 2,...
                   'Channel:Channel:invalidLimits',...
                   'STREAMLIMITS must be an vector of two doubles.');

            % Create underlying C++ channel implementation.
            obj.ChannelImpl = asyncioimpl.Channel(devicePluginPath,...
                                                  converterPluginPath,...
                                                  streamLimits(1),...
                                                  streamLimits(2));
            
            % Initialize device plug-in and get custom property/value pairs.
            customProps = obj.ChannelImpl.init(options);
            
            % Add and initialize dynamic properties.
            fields = fieldnames(customProps);
            for i = 1:length(fields)
                prop = addprop(obj, fields{i});
                obj.(fields{i}) = customProps.(fields{i});
                prop.SetAccess = 'protected';
                prop.SetObservable = true;
            end
            
            % Create the input/output streams.
            obj.InputStream = asyncio.InputStream(obj.ChannelImpl);
            obj.OutputStream = asyncio.OutputStream(obj.ChannelImpl);
            
            % Do post init functionality (can be overridden by a subclass).
            obj.postInit();
        end  
        
        function delete(obj)
        % DELETE Destroy the communications channel.
        %
        % If the communication channel is still open, it will be closed
        % and all data in the input and output streams will be lost.
            
            % Make sure we are closed.
            if isOpen(obj)
                warning('Channel:delete:channelOpenDuringDelete',...
                        'Channel is being deleted while still open.');
                obj.close();
            end
            
            % Do pre-term functionality (can be overridden by a subclass).
            obj.preTerm();
            
            % Terminate device plug-in.
            obj.ChannelImpl.term();

            % Delete streams.
            delete(obj.InputStream);
            delete(obj.OutputStream);
                        
            % Delete underlying channel implementation.
            delete(obj.ChannelImpl);
        end
            
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Getters/Setters
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

        function result = isOpen(obj)
        % ISOPEN Return true is the channel is open, false otherwise.
        
            assert( isscalar(obj), 'Channel:isOpen:notScalar',...
                                   'OBJ must be scalar.');
            result = obj.ChannelImpl.isOpen();
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Commands
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
        
        function open(obj, options)
        % OPEN Connect to the device and begin the streaming of data.
        % 
        % OPEN(OBJ,OPTIONS) opens the communication channel, gains
        % exclusive access to any resources, and allows the device 
        % to begin sending and receiving data.
        %
        % Inputs:
        % OPTIONS - A structure containing information that needs to be passed 
        % to the device plug-in prior to opening. This parameter is optional 
        % and defaults to an empty structure.
        %
        % Notes:
        % Open does not flush either the input stream or the output stream.
        % To alter this behavior, override the preOpen method.

            assert( isscalar(obj), 'Channel:open:notScalar',...
                                   'OBJ must be scalar.');
                               
            % If no options specified...
            if nargin < 2 || isempty(options)
                options = struct([]);
            end

            if isOpen(obj)
                return;
            end
                
            % Do pre-open functionality (can be overridden by a subclass).
            obj.preOpen();
                
            % Gain exclusive access of the device.
            obj.ChannelImpl.open(options);
            
            % Notify any listeners that we have opened.
            notify(obj, 'Opened');
        end
        
        function close(obj)
        % CLOSE Disconnect from the device and stop the streaming of data.
        % 
        % CLOSE(OBJ) stops the streaming of data, releases exclusive access
        % to any resources, and closes the communication channel.
        %
        % Notes:
        % Close does not flush either the input stream or the output stream.
        % To alter this behavior, override the postClose method.
            assert( isscalar(obj), 'Channel:close:notScalar',...
                                   'OBJ must be scalar.');
                               
            if ~isOpen(obj)
                return;
            end
                
            % Release exclusive access to the device.
            obj.ChannelImpl.close();
            
            % Do post-close functionality (can be overridden by a subclass).
            obj.postClose();

            % Notify any listeners that we have closed.
            notify(obj, 'Closed');
        end
        
        function execute(obj, command, options)
        % EXECUTE Execute an arbitrary device-specific command.
        % 
        % EXECUTE(OBJ,COMMAND,OPTIONS) will pass the given command and
        % options to the device plug-in.
        %
        % Inputs:
        % COMMAND - A string that represents the command to execute.
        % OPTIONS - A structure containing information that needs to be passed 
        % to the device plug-in in order to execute the command. This 
        % parameter is optional and defaults to an empty structure.
        %
        % Notes: 
        % Execute can be called at any time, not just when the channel is open.
        % Errors, warnings, custom events, and custom property updates are
        % propagated as usual during execute.

            assert( isscalar(obj), 'Channel:execute:notScalar',...
                                   'OBJ must be scalar.');
        
            % If no options specified...
            if nargin < 3 || isempty(options)
                options = struct([]);
            end
            
            obj.ChannelImpl.execute(command, options);
        end        
    end
    
    methods(Access='protected')
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Helpers
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
        
        function postInit(obj)
        % Functionality done just after channel is created.
        
            % Connect property, message, and event callbacks to our methods.    
            obj.ChannelImpl.PropertyEventFcn = @(source,event) ...
                obj.onPropertyEvent(event.Type, event.Data);
               
            obj.ChannelImpl.MessageEventFcn = @(source,event) ...
                obj.onMessageEvent(event.Type, event.Data.ID, event.Data.Text);

            obj.ChannelImpl.CustomEventFcn = @(source,event) ...
                obj.onCustomEvent(event.Type, event.Data);
        end
        
        function preOpen(obj)
        % Functionality done just prior to device being opened.

            % Connect data flow callbacks to our methods.    
            obj.ChannelImpl.DataReceivedFcn = @(source,event) ...
                obj.onDataReceived();
         
            obj.ChannelImpl.DataSentFcn = @(source,event) ...
                obj.onDataSent();            
        end
        
        function postClose(obj)
        % Functionality done just after device is closed.

            % Disconnect data flow callbacks. 
            % This has the effect of stopping the transfer of events 
            % that may have been queued by the data source or sink but 
            % have not yet been processed by MATLAB.            
            obj.ChannelImpl.DataSentFcn = [];
            obj.ChannelImpl.DataReceivedFcn = [];
        end
        
        function preTerm(obj)
        % Functionality done just before channel is destroyed.
        
            % Disconnect property, message, and event callbacks. 
            % This has the effect of stopping the transfer of events 
            % that may have been queued by the device but have not yet
            % processed by MATLAB.            
            obj.ChannelImpl.CustomEventFcn = [];
            obj.ChannelImpl.MessageEventFcn = [];
            obj.ChannelImpl.PropertyEventFcn = [];
        end
    end 
    
    methods(Access='private')
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Event handlers
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
        
        function onPropertyEvent(obj, name, value)
            % Handle property update from device plug-in. 
            obj.(name) = value;
        end
        
        function onMessageEvent(obj, type, id, text)
            % Handle message from device plug-in.
            switch (type)
                case 'error'
                    obj.close();
                    error(id, text); 
                case 'warning'
                    prevState = warning('off','backtrace');
                    warning(id, text);
                    warning(prevState);
                case 'trace'
                    if obj.TraceEnabled
                        disp(text);
                    end
                otherwise
                    assert(false, 'Unknown message type.');
            end
        end
        
        function onCustomEvent(obj, type, data)
            % Handle custom event from device plug-in.
            % Notify any listeners.
            notify(obj, 'Custom', asyncio.CustomEventInfo(type,data));
        end
        
        function onDataReceived(obj)
            % Handle data received event from engine.
            
            % Notify any listeners with the amount of data available.
            % If no data is available to read, don't send the event.
            count = obj.InputStream.DataAvailable;
            if count > 0
                notify(obj.InputStream, 'DataWritten', ...
                       asyncio.DataEventInfo(count));
            end
        end
        
        function onDataSent(obj)
            % Handle data sent event from engine.
            
            % Notify any listeners with the amount of space available.
            % If no space is available to write, don't send the event.
            space = obj.OutputStream.SpaceAvailable;
            if space > 0
                notify(obj.OutputStream, 'DataRead', ...
                       asyncio.DataEventInfo(space));
            end
        end
    end
    
    properties(Hidden=true)
        % Enables/disables trace statements from plug-ins.
        TraceEnabled = false;   
    end    
            
    properties(GetAccess='private',SetAccess='private')
        % Underlying C++ implementation of channel.
        ChannelImpl;    
    end
end
