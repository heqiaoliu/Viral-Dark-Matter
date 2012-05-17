classdef SampleTime
% Simulink.SampleTime - Contains information related to a sample time.
% 
% A Simulink.SampleTime has the following fields:
%
%     Value: A two-element array of doubles that contains the sample 
%            time period and offset
%
%     Description: A character string that describes the sample time type
%
%     ColorRGBValue: A 1x3 array of doubles that contains the red, 
%                    green and blue (RGB) values of the sample time color
%
%     Annotation: A character string that represents the annotation of a 
%                 specific sample time (e.g., 'D1')
%
%     OwnerBlock: For asynchronous and variable sample times, a string 
%                 containing the full path to the block that controls 
%                 the sample time. For all other types of sample times,
%                 an empty string.
%
%     ComponentSampleTimes:  An array of Simulink.SampleTime objects if 
%                            the sample time is an async union or if the 
%                            sample time is hybrid and the component 
%                            sample times are available.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ 
    
    properties
        Value
        Description
        ColorRGBValue
        Annotation
        OwnerBlock
        ComponentSampleTimes = Simulink.SampleTime.empty(0,0);
    end
    
    methods
        function tsObj = SampleTime(tsStructIn)
            if(isfield(tsStructIn,'Value'))
                if(isempty(tsStructIn.Value) || ...
                    (tsStructIn.Value(1) >=0) )
                    tsObj.Value = tsStructIn.Value;
                else 
                    tsObj.Value = [];
                end
            end
            if(isfield(tsStructIn,'Description'))
                tsObj.Description = tsStructIn.Description;
            end
            if(isfield(tsStructIn,'ColorRGBValue'))
                tsObj.ColorRGBValue = tsStructIn.ColorRGBValue;
            end
            if(isfield(tsStructIn,'Annotation'))
                tsObj.Annotation = tsStructIn.Annotation;
            end                
            if(isfield(tsStructIn,'OwnerBlock'))
                tsObj.OwnerBlock = tsStructIn.OwnerBlock;
            end
            if(isfield(tsStructIn,'ComponentSampleTimes'))
                for idx=1:length(tsStructIn.ComponentSampleTimes)
                    tmpObj = Simulink.SampleTime(tsStructIn.ComponentSampleTimes(idx));
                    tsObj.ComponentSampleTimes(idx) = tmpObj;

                end
            end
        end
    end
end

