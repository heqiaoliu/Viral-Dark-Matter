classdef (Hidden) IPlugin  < handle
    %IPLUGIN Define the interface for VIDEOWRITER plugins
    %   Plugins are the utility used by VIDEOWRITER to connect the
    %   user-visible VIDEOWRITER object to the code that is responsible for
    %   actually writing data to the disk.
    %
    %   This is an internal class and is not intended for customer use.
    
    % Copyright 2009-2010 The MathWorks, Inc.
    % $Revision: 1.1.6.3 $ $Date: 2010/04/21 21:29:49 $
    
    properties (Abstract)
        ColorFormat; % The format in which data is written to the disk, e.g. RGB24
        ColorChannels; % The number of channels in the output.  Normally 1 or 3.
        BitsPerPixel; % The number of bits in an output pixel, e.g. 24 for RGB24 or 8 for MONO8.
    end
    
    properties(Access=protected, Transient)
        Channel; % The low-level API interface.
    end
    
    methods(Abstract)
        open(obj);
        close(obj);
        writeVideoFrame(obj);
    end
    
    methods
        function delete(obj)
            % Close the object and destroy the reference to the underlying
            % channel object.
            
            close(obj);
            delete(obj.Channel);
        end
    end
end
