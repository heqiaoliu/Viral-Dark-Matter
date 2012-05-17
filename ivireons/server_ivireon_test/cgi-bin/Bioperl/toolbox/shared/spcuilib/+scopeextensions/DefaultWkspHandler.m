classdef DefaultWkspHandler < scopeextensions.AbstractWkspHandler
    %DEFAULTWKSPHANDLER Define the DefaultWkspHandler class.
    
    %   Copyright 2008-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.4 $  $Date: 2009/10/29 16:07:48 $
    
    methods
        
        % Constructor
        function this = DefaultWkspHandler(hSource, varargin)
            
            this@scopeextensions.AbstractWkspHandler(hSource, ...
                uiscopes.CoreData, varargin{:});
            
            if ~this.isDataValid(this.UserData)
                this.ErrorStatus = 'failure';
                this.ErrorMsg    = uiscopes.message('OnlyDoublesAccepted');
                return;
            end
            
            allSizes = size(this.UserData);
            
            % If there are only 2 dimensions to the input there is only a
            % single frame.
            if length(allSizes) < 3
                allSizes(3) = 1;
            end
            
            % Cache the dimensions of the data.
            this.Data.Dimensions = allSizes(1:end-1);
            this.Data.NumFrames = allSizes(end);
        end
    end
    methods (Static)
        function [valid, errMsg] = isDataValid(myData)
            valid = true;
            errMsg = '';
            
            if ~(isa(myData, 'double'))
                valid = false;
                errMsg  = uiscopes.message('OnlyDoublesAccepted');
            end
            
        end
        
    end
end
