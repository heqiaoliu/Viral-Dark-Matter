classdef icinterface < instrument
    %ICINTERFACE Construct icinterface object.
    %
    %   ICINTERFACE constructs the parent class for interface objects.
    %   Interface objects include: serial port, GPIB, VISA, TCPIP and
    %   UDP objects.
    %
    %   Note, the GPIB, VISA, TCPIP and UDP objects are included with the
    %   Instrument Control Toolbox.
    %
    %   An interface object is instantiated with the SERIAL, GPIB, VISA,
    %   TCPIP and UDP constructors. This constructor should not be called
    %   directly by users.
    %
    %   See also SERIAL.
    %
    
    %   MP 9-03-02
    %   AL 9-4-2009    
    %   Copyright 1999-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.2 $  $Date: 2009/11/07 21:22:26 $
        
    methods
        function obj = icinterface(validname)         
            obj = obj@instrument(validname);
            obj.store = {};
        end
    end
    
    
    
end

