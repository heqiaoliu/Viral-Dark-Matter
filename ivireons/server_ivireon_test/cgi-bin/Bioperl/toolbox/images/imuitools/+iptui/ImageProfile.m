classdef ImageProfile < handle
    %Create image profile object.
    %
    % The ImageProfile object is designed to be a return argument of
    % improfilepanel and is not intended to be instantiated directly. The
    % ImageProfile object returns the current Intensity and Sample Point
    % information of an associated imageprofilepanel.
    %
    %   Properties
    %   -------
    %   Type "properties iptui.ImageProfile" to see a list of the properties.
    %
    %   For more information about a particular property, type
    %   "help ImageProfile.propertyname" at the command line.
    %
    %   Methods
    %   -------
    %   Type "methods iptui.ImageProfile" to see a list of the methods.
    %
    %   For more information about a particular method, type
    %   "help ImageProfile.methodname" at the command line.
    
    %   Copyright 2008 The MathWorks, Inc.
    %   $Revision: 1.1.6.1 $ $Date: 2008/10/02 18:56:17 $
    
    properties (SetAccess = 'private',GetAccess = 'public')
        
        Intensity % Pixel intensity along ROI perimeter
        SamplePoints % Sampled positions along ROI perimeter
        
    end
    
    properties (SetAccess = 'private',GetAccess = 'private', Hidden = true)
        
        hProfilePanel
        
    end
    
    methods
        
        function obj = ImageProfile(hProfilePanel)
            
            obj.hProfilePanel = hProfilePanel;
            obj.Intensity = [];
            obj.SamplePoints = [];
            
        end
        
        function intensity_out = get.Intensity(obj)
            
            try
                [x,y,intensity] = obj.hProfilePanel.computeProfile();
                intensity_out = intensity;
            catch %#ok<CTCH>
                % If computeProfile method of the profile panel object
                % should fail for any reason, return empty to signal that
                % the ImageProfile object is in an invalid state.
                intensity_out = [];
            end
            
        end
        
        function sample_pts_out = get.SamplePoints(obj)
            
            try
                [x,y] = obj.hProfilePanel.computeProfile();
                sample_pts_out = [x,y];
            catch %#ok<CTCH>
                % If computeProfile method of the profile panel object
                % should fail for any reason, return empty to signal that
                % the ImageProfile object is in an invalid state.
                sample_pts_out = [];
            end
            
        end
        
    end
    
end