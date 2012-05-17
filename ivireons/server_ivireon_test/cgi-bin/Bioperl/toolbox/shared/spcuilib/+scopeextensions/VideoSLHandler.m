classdef VideoSLHandler < scopeextensions.AbstractSLHandler
    %VIDEOSLHANDLER Define the VideoSLHandler class.
    
    %   Copyright 2008-2010 The MathWorks, Inc.
    %   $Revision: 1.1.6.12 $  $Date: 2010/05/20 03:07:37 $
    
    methods
        function this = VideoSLHandler(srcObj, varargin)
            %VIDEOSLHANDLER Construct a VIDEOSLHANDLER object
            
            this@scopeextensions.AbstractSLHandler(srcObj);
        end
        
        % -----------------------------------------------------------------
        function [b, exception] = validateSource(this, hSource)
            
            if nargin < 2
                hSource = this.Source;
            end
            
            b = true;
            exception = MException.empty;
            
            % Supporting video singals from different block is not common use
            % case. So disable for now until we find it useful.
            args = commandLineArgs(hSource);
            if isempty(args{1})
                return;
            end
            
            blockNames = unique(args{1}(:,1));
            if iscell(blockNames) && numel(blockNames) > 1
                b = false;
                errMsg = 'Selected video signals must be from same Simulink block';
                exception = MException('spcuilib:scopes:InvalidVideoBlockSelection', errMsg);
            end
        end
        
        % -----------------------------------------------------------------
        function msg = emptyFrameMsg(this) %#ok
            %EMPTYFRAMEMSG Text message indicating likely cause of 0x0 video frame size
            
            % This message should never appear until Simulink supports empty signals
            msg = 'Video frame contains no data (size is 0x0)';
        end
    end
end
