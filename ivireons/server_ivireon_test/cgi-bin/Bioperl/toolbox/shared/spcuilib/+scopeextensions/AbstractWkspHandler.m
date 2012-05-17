classdef AbstractWkspHandler < uiscopes.AbstractDataHandler
    %ABSTRACTWKSPHANDLER Define the AbstractWkspHandler class.
    
    %   Copyright 2008-2010 The MathWorks, Inc.
    %   $Revision: 1.1.6.6 $  $Date: 2010/03/31 18:40:42 $
    
    properties (Access = protected)
        FrameFcn = @getframe;
    end
    
    methods
        function this = AbstractWkspHandler(hSource, hData, varargin)
            this@uiscopes.AbstractDataHandler(hSource);
            
            needsEval = false;
            if isa(varargin{1}, 'uiscopes.ScopeCLI')
                % In this situation, we don't have an actual string to
                % evaluate, rather an evaluated expression directly from
                % the command line.  We will make up a string (use the
                % default: '') and place the evaluated expression in
                % another property
                hCLI = varargin{1};
                values = hCLI.ParsedArgs{1};
                if ischar(values)
                    expression = values;
                    needsEval = true;
                elseif isempty(hCLI.ArgNames)
                    expression = '';
                else
                    expression = hCLI.ArgNames{1};
                end
                hSource.LoadExpr.mlvar = expression;
                if length(hCLI.ParsedArgs) > 1
                    hData.FrameRate = hCLI.ParsedArgs{2};
                end
            elseif ischar(varargin{1})
                % Expression string passed in
                hSource.LoadExpr.mlvar = varargin{1};
                needsEval = true;
                if nargin > 2
                    hData.FrameRate = varargin{2};
                end
            else
                needsEval = true;
            end
            
            this.Data = hData;
            exprStr = hSource.LoadExpr.mlvar;
            if needsEval
                % Evaluate command-line expression
                try
                    % Check for an empty string, and provide a useful error msg
                    % ("expr=evalin(...)" yields an non-helpful error msg)
                    if isempty(exprStr)
                        this.ErrorStatus = 'failure';
                        this.ErrorMsg = 'Expression is empty.';
                        return
                    end
                    
                    % Evaluate expression in the base workspace
                    values = evalin('base',exprStr);
                catch e
                    % For load expression dialog interaction, this catch
                    % won't occur, since the validate method on LoadExprDlg
                    % object will catch the error See the validate methods
                    % for error handling in this situation.
                    %
                    % This catch will occur if a command-line invocation of
                    % LoadExpr method occurs.
                    
                    % Improve the error if it is the generic MATLAB
                    % undefined function or variable message.
                    if strcmpi(e.identifier, 'MATLAB:UndefinedFunction')
                        errStr = sprintf('%s could not load the MATLAB expression ''%s'' because it is an undefined function or variable.', ...
                            getAppName(this.Source.Application, true), exprStr);
                    else
                        errStr = e.message;
                    end
                    
                    this.ErrorStatus = 'failure';
                    this.ErrorMsg = errStr;
                    return
                end
            end
            
            this.UserData = values;
            dims = size(this.UserData);
            this.Data.NumFrames = dims(end);
            this.Data.Dimensions = dims(1:end-1);
            
            if isempty(exprStr)
                % This default name will be overridden in top-level "mplay" function
                %   if the "inputname" call returns a non-empty string in mplay
                exprStr = '(MATLAB Expression)';
            end
            this.Source.Name      = exprStr;
            this.Source.NameShort = exprStr;  % this.SourceName;
        end
        
        function d = getTimeDimension(this)
            
            maxDimensions = size(this.UserData);
            
            d = size(maxDimensions, 2);
            
        end

        function args = commandLineArgs(this)
            %CommandLineArgs Return command-line arguments to
            %   instantiate this DataLoadWorkspace connection.
            %   Called by uiscope.source method.
            
            % Workspace-based data sources are saved by storing the actual data itself,
            % since chances are we cannot reconstruct the expression because it was never
            % known to us.  The instrument set file therefore can be quite large in this case,
            % since the MAT file will hold the actual video data.
            
            % Get actual playback rate, not "source rate"
            playbackRate = this.Source.Data.FrameRate;
            
            if isSerializable(this.Source)
                % Import edit-box is not empty
                % Just store the import string expression
                % (using the double-cell cmd-line syntax)
                %
                % Much smaller to store, but it might not evaluate
                % at a future load
                
                % Get string from import dialog edit-box
                importStr = this.Source.LoadExpr.mlvar;
                
                % Create command-line args:
                args = {{{importStr, playbackRate}}};
            else
                % Import edit-box is empty, or forced to store data itself
                %
                % If edit-box is empty, we must have obtained a command-line
                % evaluated arg and do not have a corresponding string
                %
                % In this case, we must retain the data itself
                
                % Get the actual video data and return it
                args = {this.UserData, playbackRate};
            end
        end
        
        function y = getFrameData(this,idx)
            %GETFRAMEDATA Returns idx'th video frame from a random-access data source
            
            if nargin<2
                % Get data for current frame
                % Support export call which doesn't pass idx arg
                idx = this.Source.Controls.CurrentFrame;
            end
            y = this.FrameFcn(this,idx);
        end
        
        function varName = getExportFrameName(this)
            %GETEXPORTFRAMENAME Returns string name for use when exporting
            %   frame of video data, specific to workspace variables.
            
            % This must be a valid MATLAB variable name
            %
            theFrameNum = this.Source.Controls.CurrentFrame;
            variableName = this.Source.Name;
            if isempty(variableName)
                variableName = 'frame';
            end
            varName = genvarname(sprintf('%s_%d', variableName, theFrameNum));
        end
    end
    %create an abstract method that descendants of this class must
    %implement
    methods (Static, Abstract)
        [valid, errMsg] = isDataValid(data)
    end
end

function y = getframe(this, idx) %#ok<INUSD>

evalStatement = ['this.UserData(' repmat(':,', 1, ndims(this.UserData)-1) 'idx);'];
y = eval(evalStatement);

end

