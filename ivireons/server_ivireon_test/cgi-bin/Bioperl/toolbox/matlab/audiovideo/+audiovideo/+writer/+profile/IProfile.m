classdef (Hidden) IProfile < HeterogeneousHandle
    %IProfile Base class for all VideoWriter profiles.
    %   Profiles are the mechanism used by VideoWriter to define a how data
    %   will be written to disk in certain situations.  Profiles contain a
    %   plugins, which are responsible for actually writing data to disk in
    %   the specified format, as well as properties which define any user
    %   customizable features of the plugin.
    %
    %   Profiles can be created to reflect different file types, such as
    %   avi or mov files, different codecs used to encode the data such as
    %   Motion JPEG or H.264, the default settings for compression, or a
    %   combination of all of these.
    %
    %   See also VideoWriter.

    % Copyright 2009-2010 The MathWorks, Inc.
    % $Revision: 1.1.6.5 $ $Date: 2010/05/10 17:22:53 $
    
    properties (Abstract, SetAccess=protected)
        %VideoProperties The properties object for the profile.
        %   The VideoProperties property is expected to contain an instance
        %   of an audiovideo.writer.properties.VideoProperties object or a
        %   subclass of that class.
        VideoProperties
        %Name The name of the profile
        Name
        %Description A very brief description of the purpose of the %profile.
        Description
    end
    
    properties (Abstract, Constant)
        %FileExtensions A cell array of the valid file extentsion.
        %   This is a cell array of the valid file extensions for the
        %   profile.  The extension should contain the '.' character.
        %
        %   Example:
        %      FileExtensions = {'.avi'};
        FileExtensions
    end
    
    properties (Abstract, Constant, Hidden)
        %FileFormat A brief description of the file format.
        FileFormat
    end
    
    properties (Hidden, SetAccess=protected)
        %PreferredDataType The data type used by the profile.
        %   The PreferredDataType property is a string representing the
        %   class that the profile expects for input data.  Most profiles
        %   will accept uint8 data since most video files are uint8.  The
        %   VideoWriter object will convert data to this type before calling
        %   the writeVideoFrame method of the plugin.
        PreferredDataType = 'uint8';
    end
    
    properties(Abstract, Access=protected)
        %PLUGIN Object responsible for actually writing data to the disk.
        %   The Plugin object is the object that is responsible for writing
        %   data to the disk.  It must be an instance of an object
        %   implementing the audiovideo.internal.writer.plugin.IPlugin
        %   interface.
        Plugin
    end
    
    methods
        function prof = IProfile()
        end
        
        function writeVideoFrame(obj, frame)
            % WRITEVIDEOFRAME Write a single frame to the plugin.
            obj.Plugin.writeVideoFrame(frame);
            obj.VideoProperties.frameWritten(frame);
        end
    end
    
    methods (Abstract=true)
        open(obj);
        close(obj);
    end

    methods (Hidden=true)
        % Methods inherited from the base class.  These are implemented by
        % delegating the base class but are hidden to simplify the
        % interface.
        
        function res= addlistener(obj, varargin)
            res = addlistener@HeterogeneousHandle(obj, varargin);
        end
        function res= eq(obj, varargin)
            res = eq@HeterogeneousHandle(obj, varargin);
        end
        function res= findobj(obj, varargin)
            res = findobj@HeterogeneousHandle(obj, varargin);
        end
        function res= findprop(obj, varargin)
            res = findprop@HeterogeneousHandle(obj, varargin);
        end
        function res= ge(obj, varargin)
            res = ge@HeterogeneousHandle(obj, varargin);
        end
        function res= gt(obj, varargin)
            res = gt@HeterogeneousHandle(obj, varargin);
        end
        function res= le(obj, varargin)
            res = le@HeterogeneousHandle(obj, varargin);
        end
        function res= lt(obj, varargin)
            res = lt@HeterogeneousHandle(obj, varargin);
        end
        function res= ne(obj, varargin)
            res = ne@HeterogeneousHandle(obj, varargin);
        end
        function res= notify(obj, varargin)
            res = notify@HeterogeneousHandle(obj, varargin);
        end
    end
    
    methods (Static, Sealed, Access=protected)
        function obj = getDefaultScalarElement()
            % getDefaultScalarElement Return a base object of the class type.
            %
            %   This method is used internally to satisfy the requirements for
            %   use of heterogeneous arrays. Since empty profile objects
            %   are not allowed, this method errors.
            error('matlab:VideoWriter:emptyProfiles', 'Creating empty profiles is not allowed.');
        end
    end
    
end

