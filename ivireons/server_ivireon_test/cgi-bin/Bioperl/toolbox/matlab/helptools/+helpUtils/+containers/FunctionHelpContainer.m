classdef FunctionHelpContainer < helpUtils.containers.abstractHelpContainer
    % FUNCTIONHELPCONTAINER - stores help information for an M-function.
    % FUNCTIONHELPCONTAINER stores help information for an M-function that
    % is not a MATLAB Class Object System class definition.
    %
    % Remark:
    % Creation of this object should be made by the static 'create' method
    % of helpUtils.containers.HelpContainer class.
    %
    % Example:
    %    filePath = which('addpath');
    %    helpObj = helpUtils.containers.HelpContainer.create(filePath);
    %
    % The code above constructs a FUNCTIONHELPCONTAINER object.
    
    % Copyright 2009 The MathWorks, Inc.
    
    methods
        function this = FunctionHelpContainer(filePath)
            % constructor takes in 'filePath' and initializes the properties
            % inherited from the superclass.

            helpStr = builtin('helpfunc', filePath);
            mainHelpContainer = helpUtils.containers.atomicHelpContainer(helpStr);

            pkgClassNames = helpUtils.containers.getQualifiedFileName(filePath);

            [folderPath, name] = fileparts(filePath);
            
            if helpUtils.containers.isClassDirectory(folderPath)
                % True for non-local methods defined in @class folder
                mFileName = [pkgClassNames '.' name];
            else
                % This ensures that packaged M-files are treated correctly.
                mFileName = pkgClassNames;
            end
        
            this = this@helpUtils.containers.abstractHelpContainer(mFileName, filePath, mainHelpContainer);
        end
        
        function result = isClassHelpContainer(this) %#ok<MANU>
            % ISCLASSHELPCONTAINER - returns false because object is of
            % instance FunctionHelpContainer, not ClassHelpContainer
            result = false;
        end
    end
    
end

