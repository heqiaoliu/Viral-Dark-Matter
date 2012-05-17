classdef serial < icinterface
    %SERIAL Construct serial port object.
    %
    %   S = SERIAL('PORT') constructs a serial port object associated with
    %   port, PORT. If PORT does not exist or is in use you will not be able
    %   to connect the serial port object to the device.
    %
    %   In order to communicate with the device, the object must be connected
    %   to the serial port with the FOPEN function.
    %
    %   When the serial port object is constructed, the object's Status property
    %   is closed. Once the object is connected to the serial port with the
    %   FOPEN function, the Status property is configured to open. Only one serial
    %   port object may be connected to a serial port at a time.
    %
    %   S = SERIAL('PORT','P1',V1,'P2',V2,...) constructs a serial port object
    %   associated with port, PORT, and with the specified property values. If
    %   an invalid property name or property value is specified the object will
    %   not be created.
    %
    %   Note that the property value pairs can be in any format supported by
    %   the SET function, i.e., param-value string pairs, structures, and
    %   param-value cell array pairs.
    %
    %   Example:
    %       % To construct a serial port object:
    %         s1 = serial('COM1');
    %         s2 = serial('COM2', 'BaudRate', 1200);
    %
    %       % To connect the serial port object to the serial port:
    %         fopen(s1)
    %         fopen(s2)
    %
    %       % To query the device.
    %         fprintf(s1, '*IDN?');
    %         idn = fscanf(s1);
    %
    %       % To disconnect the serial port object from the serial port.
    %         fclose(s1);
    %         fclose(s2);
    %
    %   See also SERIAL/FOPEN.
    %
    
    %   MP 7-13-99
    %   AL 9-4-2009
    %   Copyright 1999-2009 The MathWorks, Inc.
    %   $Revision: 1.10.4.13 $  $Date: 2009/10/16 05:01:57 $
    
    properties(Hidden, SetAccess = 'public', GetAccess = 'public')
        icinterface
    end
    
    
    
    methods
        function obj = serial(varargin)
            
            obj = obj@icinterface('serial'); %#ok<PROP>
            
            try
                obj.icinterface =  icinterface('serial');
            catch %#ok<CTCH>
                error('MATLAB:serial:serial:nojvm', 'Serial port objects require JAVA support.');
            end
            
            
            
            
            switch (nargin)
                case 0
                    error('MATLAB:serial:serial:invalidSyntax', 'The PORT must be specified.');
                case 1
                    if (ischar(varargin{1}))
                        % Ex. s = serial('COM1')
                        % Call the java constructor and store the java object in the
                        % serial object.
                        if isempty(varargin{1})
                            error('MATLAB:serial:serial:invalidPORT', 'The PORT must be a non-empty string.');
                        end
                        try
                            
                            obj.jobject = handle(javaObject('com.mathworks.toolbox.instrument.SerialComm',varargin{1}));
                        catch aException
                            error('MATLAB:serial:serial:cannotCreate', aException.message);
                        end
                        
                        %%% Remove
                        obj.type  = 'serial';
                        %                         obj.constructor = 'serial';
                        
                    elseif strcmp(class(varargin{1}), 'serial')
                        obj = varargin{1};
                    elseif isa(varargin{1}, 'com.mathworks.toolbox.instrument.SerialComm')
                        obj.jobject = handle(varargin{1});
                        obj.type = 'serial';
                        %                         obj.constructor = 'serial';
                    elseif isa(varargin{1}, 'javahandle.com.mathworks.toolbox.instrument.SerialComm')
                        obj.jobject = varargin{1};
                        obj.type = 'serial';
                        %                         obj.constructor = 'serial';
                    elseif ishandle(varargin{1})
                        % True if loading an array of objects and the first is a GPIB object.
                        if isa(varargin{1}(1), 'javahandle.com.mathworks.toolbox.instrument.SerialComm')
                            obj.jobject = varargin{1};
                            obj.type = 'serial';
                            %                             obj.constructor = 'serial';
                        else
                            error('MATLAB:serial:serial:invalidPORT', 'Invalid PORT specified.');
                        end
                    else
                        error('MATLAB:serial:serial:invalidPORT', 'Invalid PORT specified.');
                    end
                otherwise
                    % Ex. s = serial('COM1', 'BaudRate', 4800);
                    try
                        % See g405634 for why we use javaObject
                        obj.jobject = handle(javaObject('com.mathworks.toolbox.instrument.SerialComm',varargin{1}));
                    catch aException
                        error('MATLAB:serial:serial:cannotCreate', aException.message);
                    end
                    obj.type = 'serial';
                    %                     obj.constructor = 'serial';
                    % Try setting the object properties.
                    try
                        set(obj, varargin{2:end});
                    catch aException
                        delete(obj);
                        localFixError(aException);
                    end
            end
          
            % Set Constructor types             
            setMATLABClassName( obj.jobject(1),obj.constructor);
               
            if isvalid(obj)
                % Pass the OOPs object to java. Used for callbacks.
                obj.jobject(1).setMATLABObject(obj);
            end
        end     
    end
    
    
    % Separate Files
    methods(Static)
        obj = loadobj(B);
    end
    
    
    
end


% *******************************************************************
% Fix the error message.
function localFixError(aException)

errmsg = aException.message;

% Remove the trailing carriage returns from errmsg.
while errmsg(end) == sprintf('\n')
    errmsg = errmsg(1:end-1);
end

throwAsCaller(MException(aException.identifier, errmsg));

end


