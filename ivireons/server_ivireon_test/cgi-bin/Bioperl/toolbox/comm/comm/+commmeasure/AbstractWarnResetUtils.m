classdef (Hidden) AbstractWarnResetUtils < handle
    %AbstractWarnResetUtils Defines AbstractWarnResetUtils abstract class
    %for COMMMEASURE package
    
    %   Copyright 2009 The MathWorks, Inc.
    %   $Revision: 1.1.8.3 $  $Date: 2009/07/27 20:09:30 $

    %======================================================================
    % Protected properties
    %======================================================================    
    properties (Access = protected, Hidden = true)
        %PrivResetFlag Reset flag
        %   Use this flag to signal a reset       
        PrivResetFlag        
    end
    %======================================================================
    % Protected methods
    %======================================================================   
    methods(Access = protected)
    %=====================================================================
    function warnAboutIrrelevantSet(obj,propertyName,class) %#ok<MANU>
        %warnAboutIrrelevantSet Warn about irrelevant set
        %   Warn when the user attempts to set an irrelevant property.
        id = 'irrelevantPropertySet';
        warning(generatemsgid(id),['The %s property is not relevant ',...
                'in this configuration of %s.'],propertyName,class);            
    end
    %=====================================================================
    function warnAboutInvalidStateChange(obj,class) %#ok<MANU>
        %warnAboutInvalidStateChange Warn about invalid state change
        warning(generatemsgid('invalidStateChange'),...
            ['The %s object has been reset due to changes in ',...
            'input specifications at run time. This will affect ',...
            'performance.'],class);
    end    
    %=====================================================================
    function checkResetFlagAndReset(obj)
        %checkResetFlagAndReset Check reset flag and reset
        %   Call reset if PrivResetFlag is false.
        if ~obj.PrivResetFlag
            reset(obj);
        end
    end         
    end
end