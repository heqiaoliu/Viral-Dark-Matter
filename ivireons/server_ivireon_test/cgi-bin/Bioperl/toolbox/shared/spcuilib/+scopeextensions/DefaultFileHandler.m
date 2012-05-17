classdef DefaultFileHandler < scopeextensions.AbstractFileHandler
    %DEFAULTFILEHANDLER Define the scopeextensions.DefaultFileHandler
    %class.

    %   Copyright 2008-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.2 $  $Date: 2009/04/27 19:53:25 $

    methods

        % Constructor
        function this = DefaultFileHandler(hSource, varargin)
            this@scopeextensions.AbstractFileHandler(hSource);
            this.Data = uiscopes.CoreData;
            this.ErrorStatus = 'failure';
            this.ErrorMsg = sprintf('Cannot read files while using the %s visual.', ...
                hSource.Application.Visual.Config.Name);
        end
        function disconnectData(this) %#ok
            % NO OP
        end

        function y = getFrameData(this, idx) %#ok
            y = [];
        end
    end
end
