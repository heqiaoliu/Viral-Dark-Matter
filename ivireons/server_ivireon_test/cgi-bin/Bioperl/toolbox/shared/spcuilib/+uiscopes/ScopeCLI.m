classdef ScopeCLI < handle
    %ScopeCLI   Define the ScopeCLI class.
    %
    %    ScopeCLI methods:
    %       checkSource - Check if the source is valid.
    %       parseCmdLineArgs - Parse the command line inputs.
    %
    %    ScopeCLI properties:
    %       Name
    %       Args
    %       ArgNames
    %       ParsedArgs
    
    %   Copyright 2008-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.2 $  $Date: 2009/05/23 08:12:01 $
    
    properties
        % Name of registered source extension
        Name = '';
        
        % Cell-vector of arguments
        Args = {};
        
        % Parsed arguments
        ParsedArgs = {};
        
        % Variable name used for each argument
        ArgNames = {};
    end
    
    methods
        
        function this = ScopeCLI(args, argNames)
            %SCOPECLI Construct a SCOPECLI object
            
            % Prevent warnings from clear classes.
            mlock;
            
            if nargin>0
                this.Args = args;
            end
            if nargin>1
                this.ArgNames = argNames;
            end
        end
        function parseCmdLineArgs(this)
            %PARSECMDLINEARGS parse command line inputs

            parseCmdLineArgsBase(this);
        end
        
        function checkSource(this)
            %CHECKSOURCE check if source exists
                        
            % Make sure that we parse the command line arguments.  This method will
            % populate ParsedArgs and the correct source name which are both needed.
            this.parseCmdLineArgs;
            
            %Check if file eixsts
            if strcmp(this.Name,'File')
                source = this.ParsedArgs{1};
                if exist(source, 'file') ~= 2
                    error('spcuilib:uiscopes:ScopeCLI:checkSource:InvalidFileName', 'File ''%s'' not found.', source);
                end
                
            elseif strcmp(this.Name,'Simulink')
                if ischar(this.ParsedArgs{1}{1})
                    %Check Simulink model
                    source = strtok(this.ParsedArgs{1}{1},'/');
                    if exist(source, 'file') ~= 4
                        error('spcuilib:uiscopes:ScopeCLI:checkSource:InvalidModelName', 'Model ''%s'' not found.', source);
                    end
                elseif ~ishandle(this.ParsedArgs{1}{1})
                    error('spcuilib:uiscopes:ScopeCLI:checkSource:InvalidSimulinkHandle', 'Input Simulink handle is invalid.');
                end
                % Simulink source can have 1 input, path to the block.
                error(nargchk(1,1,length(this.ParsedArgs), 'struct'));
            end
            
            if any(strcmp(this.Name, {'Workspace', 'File'}))
                
                % Workspace source can have 1 or 2 inputs, filename and optional fps.
                error(nargchk(1,2,length(this.ParsedArgs), 'struct'))
                
                % Check that FPS is valid.
                if length(this.ParsedArgs) > 1
                    fps = this.ParsedArgs{2};
                    if ~isnumeric(fps) || isnan(fps) || isinf(fps) || ~isreal(fps)
                        error('spcuilib:uiscopes:ScopeCLI:checkSource:InvalidFPS', ...
                            'The FPS input must be a finite real double scalar.');
                    end
                end
            end
            
            % Remove the parsing.
            this.Name = '';
            this.ParsedArgs = '';
            
        end
        function hScopeCLI = copy(this)
            hScopeCLI = uiscopes.ScopeCLI(this.Args, this.ArgNames);
            
            hScopeCLI.Name       = this.Name;
            hScopeCLI.ParsedArgs = this.ParsedArgs;
        end
    end
    
    methods (Access = protected)
        function parseCmdLineArgsBase(this)
            %PARSECMDLINEARGSBASE parse command line inputs
            
            this.ParsedArgs = this.Args;
            if isempty(this.Args)
                % No user arguments
                % Substitute an empty input matrix
                this.Name = '';
            elseif iscell(this.Args{1})
                % Could be expression string or Simulink
                v=this.Args{1};
                if ~isempty(v) && iscell(v{1})
                    % expression string in a double-cell
                    % could also have {{'expr',FPS}} so pass all contents
                    w=v{1};
                    this.Name = 'Workspace';
                    this.ParsedArgs = w;
                else
                    % Simulink {block} or {block,port} or {handle}
                    this.Name = 'Simulink';
                end
                
            elseif ischar(this.Args{1})
                % Connect to file
                this.Name = 'File';
            elseif ~isempty(this.Args{1})
                % Load from workspace
                this.Name = 'Workspace';
            end
        end
    end
end

% [EOF]
