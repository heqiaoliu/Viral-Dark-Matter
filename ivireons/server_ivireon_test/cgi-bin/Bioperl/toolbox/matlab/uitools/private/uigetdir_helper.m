function [dirname] = uigetdir_helper(varargin)
% $Revision: 1.1.8.5 $  $Date: 2008/11/04 21:21:37 $
% Copyright 2006-2008 The MathWorks, Inc.
    % Initialize return value of dirname (uigetdir expects a null
    % directory name to be 0).
    dirname = 0;

    % To get the type, use varargin{1} {curly braces}.
    % 0 = uigetfile, 1 = uiputfile, 
    % 2 = uigetdir if we can combine these two files.
    % To strip the first argument off and use the rest, 
    % use vararg = vararg(2:end) {parentheses}.
    % We may not need to do this arg manipulation.
    % dialog_type = 2; 
    numArgs = nargin;

    % Check the number of arguments, if more than the maximum
    % (uigetfile = 7, uiputfile = 5, uigetdir = 2), error out.
    error(nargchk(0, 2, nargin));

    % Parse the input variables.
    [dialog_title, dialog_pathname] = parseArguments();

    % Call UiDirDialog.
    warning('off', 'MATLAB:class:inUseRedefined')
    dirdlg = UiDialog.UiDirDialog();
    warning('on', 'MATLAB:class:inUseRedefined')
    
    dirdlg.InitialPathName = dialog_pathname;
    dirdlg.Title = dialog_title;

    dirdlg.show();
    
    % if dirname empty, return 0 for uigetdir.
    dirname = dirdlg.SelectedFolder;
    if (isempty(dirname))
        dirname = 0;
    end
   
    % Done. MCOS Object dirdlg cleans up and its java peer at the end of its
    % scope(AbstractDialog has a destructor that every subclass
    % inherits)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                                                                     Nested Functions                                                                % 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [dialog_title, dialog_pathname] = parseArguments()

        % Initialize all variables we will be using for UiFileDialog.
        dialog_title = sprintf('Select Directory to Open');
        dialog_pathname = '';
        
        % Check for title and set appropriate variable (must be string).
        if (numArgs > 1)
            title = varargin{2};
            dialog_title = checkString(title, 'Title');
        end

        % Parse startpath if supplied and set appropriate variable. 
        if (numArgs > 0)
            pathname = varargin{1};
            dialog_pathname = checkString(pathname, 'Pathname');

            % REMOVE BUT FLAG FOR UIDIRDIALOG.
            % If the string is not a directory name, set pathname to the "base" directory.
            % On Windows, it's the Windows Desktop dir. On UNIX systems, it's the MATLAB dir.
            %if ~(isdir(pathname))
            %   if ispc
            %        pathnane = char(com.mathworks.hg.util.dFileChooser.getUserHome());
            %        pathname = strcat(pathname, '\Desktop');
            %    else
            %        pathname = char(matlabroot);
            %    end
            %end

        end
    end

    % Check to see if the input variable is really a string; if not, error
    % out and tell the user which variable is bad.
    function [stringout] = checkString(stringin, varName)
        if ~(isempty(stringin))
            if (~(ischar(stringin) && isvector(stringin)))
                error('MATLAB:uigetdir_helper:BadStringArg',...
                '%s must be a string.', varName)
            end
            if (ischar(stringin) && isvector(stringin))
                if ~(1 == size(stringin, 1))
                    stringin = stringin';
                end
            end
        end
        stringout = stringin;
    end

end
