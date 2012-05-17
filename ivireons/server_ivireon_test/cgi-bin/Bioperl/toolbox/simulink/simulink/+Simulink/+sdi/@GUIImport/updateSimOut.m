function updateSimOut(this, varargin)

    % Run the output explorer on desired target and cache results
    %
    % Copyright 2010 The MathWorks, Inc.

    % Set mouse cursor to  hourglass
    setPointer(this, 'watch');
	
	force = [];
    
    if (nargin > 1)
        force = true;
    end

    % Mine data from workspace or file
    try
        switch this.BaseWSOrMAT
        case 'basews', this.SimOutExplorer.ExploreBaseWorkspace();
        case 'mat'
            try
                this.MATFileName = get(this.ImportFromMATEdit, 'String');
                this.SimOutExplorer.ExploreMATFile(this.MATFileName);
            catch %#ok
                if isempty(force)
                    SD = Simulink.sdi.StringDict;
                    errordlg(SD.noFileMessage, SD.noFileError, 'modal');
                end
                this.SimOutExplorer = Simulink.sdi.SimOutputExplorer;
            end
        end
    catch %#ok
        % Restore mouse pointer
        setPointer(this, 'arrow');
    end

    % Restore mouse pointer
    setPointer(this, 'arrow');
end