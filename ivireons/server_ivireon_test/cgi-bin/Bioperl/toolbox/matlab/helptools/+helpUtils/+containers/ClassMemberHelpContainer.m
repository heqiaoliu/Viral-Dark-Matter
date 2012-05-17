classdef ClassMemberHelpContainer < helpUtils.containers.atomicHelpContainer
    % CLASSMEMBERHELPCONTAINER - stores meta data and help comments for class member
    % A class member can be any of the following:
    % * a constructor
    % * a method
    % * a property
    % * a classdef M-file

    % Copyright 2009 The MathWorks, Inc.
    
    properties (SetAccess = private)
        metaData = []; % stores the meta data for the class member
        Name = ''; % stores the name of the class member as a string
        
        % helpContainerType - stores a string indicating the type of class
        % member this object corresponds to
        helpContainerType = '';

        % h1Flag - boolean flag indicating whether full help or H-1 line is
        % stored
        h1Flag = [];
    end
    
    methods
        function this = ClassMemberHelpContainer(helpContainerType, helpStr, metaData, h1Flag)
            % constructor takes 0 or 4 inputs.  In the latter case, the
            % constructor uses these inputs to initialize the class
            % properties.

            switch nargin
                case 4
                    if h1Flag
                        helpStr = helpUtils.containers.extractH1Line(helpStr);
                    end

                    memberName = metaData.Name;  
                                        
                case 0
                    h1Flag = [];
                    metaData = [];
                    memberName = ''; 
                    helpContainerType = '';
                    helpStr = '';
                    
                otherwise
                    error('MATLAB:ClassMemberHelpContainer:IncorrectNumArgs', ...
                        'Constructor requires either 0 or 4 input arguments');
            end

            this = this@helpUtils.containers.atomicHelpContainer(helpStr);
            this.metaData = metaData;
            this.h1Flag = h1Flag;
            this.Name = memberName;
            this.helpContainerType = helpContainerType;
        end

        function helpStr = getH1Line(this)
            % GETH1LINE - returns H-1 line string extracted from stored member help.
            if this.h1Flag
                helpStr = this.getHelp;
            else
                helpStr = getH1Line@helpUtils.containers.atomicHelpContainer(this);
            end
        end

    end    
end

