classdef instrument
    %INSTRUMENT Construct instrument object.
    %
    %   INSTRUMENT is the base class from which interface and device objects
    %   are derived from. Interface objects are serial port, TCPIP, UDP,
    %   GPIB, VISA objects. Note, the GPIB, VISA, TCPIP, UDP and device objects
    %   are included with the Instrument Control Toolbox.
    %
    %   See also SERIAL.
    %
    
    %   MP 7-13-99
    %   AL 9-4-2009    
    %   Copyright 1999-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.2 $  $Date: 2009/11/07 21:22:27 $
    
    properties (Hidden, SetAccess = 'public', GetAccess = 'public')
        % Reference to the Java class
        jobject
        constructor
        type
    end
    
    properties(Hidden, SetAccess = 'public', GetAccess = 'public')
        % store - serializes the object on save
        store = {};
    end
    
    methods       
        function obj = instrument(validname)
            if (nargin == 0 || ~any(strcmp(validname, {'serial', 'gpib', 'visa', 'tcpip', 'udp', 'icdevice'})))
                % The instrument constructor was called directly.
                if isempty(which('gpib'))
                    error('MATLAB:instrument:instrument:invalidSyntax', 'An instrument object is instantiated through the SERIAL constructor.');
                else
                    error('MATLAB:instrument:instrument:invalidSyntax', 'An instrument object is instantiated through the SERIAL, GPIB, VISA, TCPIP, UDP or ICDEVICE constructor.')
                end
            end
            
            % Error if java is not running.
            if ~usejava('jvm')
                error('MATLAB:instrument:instrument:nojvm', 'The instrument object requires JAVA support.');
            end
            
            obj.constructor = class(obj);
        end      
    end
    
end