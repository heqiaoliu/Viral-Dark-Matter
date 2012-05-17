classdef CoreData < handle
    %CoreData   Define the CoreData class.
    %
    %    CoreData methods:
    %        method1 - Example method
    %
    %    CoreData properties:
    %        Prop1 - Example property

    %   Copyright 2008-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.5 $  $Date: 2010/01/25 22:46:31 $

    properties

        % Data dimensions 1-D; 2-D
        Dims = 2;
        DataType = '';
        NumFrames = 0;
        Dimensions = [0 0];
        FrameRate = 20;
        FrameData = [];
        Time = 0;
    end

    methods

        function this = CoreData
            %CoreData   Construct the CoreData class.

        end
        
        function b = isEmptyData(this)
            %isEmptyData Returns true if we contain empty data.
            b = any(this.Dimensions == 0);
        end
    end
end

% [EOF]
