classdef DefaultSLHandler < scopeextensions.AbstractSLHandler
    %DEFAULTSLHANDLER Define the scopeextensions.DefaultSLHandler class.

    %   Copyright 2008 The MathWorks, Inc.
    %   $Revision: 1.1.6.2 $  $Date: 2009/04/27 19:53:26 $

    methods

        % Constructor
        function this = DefaultSLHandler(hSource, varargin)
            this@scopeextensions.AbstractSLHandler(hSource);
            
            this.Data = uiscopes.CoreData;
        end
    end
end
