classdef HistogramWkspHandler < scopeextensions.AbstractWkspHandler
    % Defines the Histogram handler for ML variables/objects in a workspace
    
    % Copyright 2009 The MathWorks, Inc.
    % $Revision: 1.1.6.5 $     $Date: 2009/10/29 16:07:51 $
    
    methods
        function this = HistogramWkspHandler(srcObj, varargin)
            data = scopeextensions.HistogramData;
            data.FrameRate = 1;
            oldName = srcObj.Name;
            oldNameShort = srcObj.NameShort;
            
            this@scopeextensions.AbstractWkspHandler(srcObj, data, varargin{:});
            if strcmp(this.ErrorStatus, 'failure')
                return;
            end
            errMsg = install_data_info(this);
            if ~isempty(errMsg)
                this.ErrorStatus = 'failure';
                this.ErrorMsg = errMsg;
                srcObj.Name = oldName;
                srcObj.NameShort = oldNameShort;
                return;
            end
        end
        
        function errMsg = install_data_info(this)
            data = this.UserData;
            % check if the data is numeric.
            [valid, errMsg] = this.isDataValid(data);
            if ~valid; return; end
            % Since we are dealing with static data, UserData and FrameData will hold the same object.
            this.UserData = data;
            this.Data.DataType = class(data);
            this.Data.FrameData = data;
            this.Data.NumFrames = 1;
            this.Data.Dimensions = size(data);
            
            % If we made it here, we've successfully initialized the data source
            this.ErrorStatus = 'success';
        end
        
        %Override getFrameData since we don't have frames of data. Always return the entire data.
        function y = getFrameData(this, idx) %#ok
            y = this.Data.FrameData;
        end
        
        function args = commandLineArgs(this)
            if isSerializable(this.Source)
                importStr = this.Source.LoadExpr.mlvar;
                % Pass the variable.
                args = {{{importStr}}};
            else
                args = {this.UserData};
            end
        end
    end
    methods (Static = true)
        function [valid, errMsg] = isDataValid(myData)
        % Validate input data.
            valid = false;
            % check if the data is valid.
            [~,errMsg] = scopeextensions.HistogramData.checkInputData(myData);
            if isempty(errMsg)
                valid = true;
            end
        end
    end
end








