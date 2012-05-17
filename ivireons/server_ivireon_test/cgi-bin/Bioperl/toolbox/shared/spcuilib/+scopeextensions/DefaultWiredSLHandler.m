classdef DefaultWiredSLHandler < scopeextensions.AbstractWiredSLHandler
    %DefaultWiredSLHandler   Define the DefaultWiredSLHandler class.

    %   Copyright 2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.1 $  $Date: 2009/10/29 16:07:47 $

    methods

        function this = DefaultWiredSLHandler(srcObj, varargin)
            %DefaultWiredSLHandler   Construct the DefaultWiredSLHandler class.

            this@scopeextensions.AbstractWiredSLHandler(srcObj);
            this.Data = uiscopes.CoreData;
            this.ErrorStatus = 'success';
            this.ErrorMsg = '';

        end
        function frameData = getFrameData(this, ~)
            frameData = this.UserData;
        end
    end
end

% [EOF]
