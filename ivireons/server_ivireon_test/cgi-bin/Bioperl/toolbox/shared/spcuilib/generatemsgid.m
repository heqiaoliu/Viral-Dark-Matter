function msgid = generatemsgid(id, filepath)
%GENERATEMSGID Returns a message ID.
%   GENERATEMSGID(ID) Returns the message id using ID as the mnemonic.  The
%   output is defined differently depending on the type of function calling
%   GENERATEMSGID.
%
%   Function Type                 Format
%   Function                      <toolbox>:<function>:ID
%   Package function              <toolbox>:<package>:<function>:ID
%   Class method with no package  <toolbox>:<class>:<function>:ID
%   Class method with a package   <toolbox>:<package>:<class>:<function>:ID
%
%   <toolbox> - The toolbox of the calling function.  This is defined by
%               the string after <MATLABROOT>\toolbox\ and before the next
%               file separator.  Note that when this is the string 'shared'
%               GENERATEMSGID will take the next string.
%   <function> - The calling function name.  This is defined by the 'file'
%                field in the 2nd entry in the output of DBSTACK.
%   <package> - The package of the calling function.  This is also defined
%               by using the DBSTACK and searching for @ or + signs.
%   <class> - The class of the calling function.  This is also defined by
%             using the DBSTACK and searing for the last @ sign.
%
%   Examples (these are not runnable from the command window):
%   % #1 In zerophase warn about the syntax change.
%   warning(generatemsgid('syntaxChanged'), ...
%       'The syntax of the zerophase function has changed.');
%   % The ID will be 'signal:zerophase:syntaxChanged'
%
%   % #2 In the FILTER method of dfilt.singleton errors when the dimensions
%   %    are not specified as a positive integer.
%     msg = 'Dimension argument must be a positive integer scalar in the range 1 to 2^31.';
%     msgid = generatemsgid('DimMustBeInt');
%     error(msgid,msg);
%   % The ID will be 'signal:dfilt:singleton:filter:DimMustBeInt'
%
%   % #3 In shared/spcuilib/@spcuddutils/abstractmethod.m an error is
%   %    thrown indicating an abstract method.
%   id = generatemsgid('AbstractMethod')
%   % The ID will be 'spcuilib:spcuddutils:abstractmethod:AbstractMethod'
%
%   See also WARNING, ERROR.

%   Author(s): J. Schickler
%   Copyright 2002-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/05/23 08:11:56 $

error(nargchk(1, 2, nargin, 'struct'));

% Get the stack to determine the toolbox and the calling function.
if nargin < 2
    filepath = getPathFromStack;
end

% Fix the file name to remove the extension which is not needed in the ID.
filepath(end-1:end) = [];

% Cache filesep in fsep.
fsep = filesep;

% Get the ID string based on the toolbox, class info and function.
functionName = getFunctionName;
className    = getClassName;
toolboxName  = getToolboxName;

% Combine all the strings.
msgid = [toolboxName className ':' functionName ':' id];

% -------------------------------------------------------------------------
    function toolboxName = getToolboxName
        
        % Check to make sure we are in a toolbox directory.
        toolboxIndex = strfind(filepath, 'toolbox');
        if isempty(toolboxIndex)
            
            % If we don't have 'toolbox' in the path, get the parent
            % directory for the calling function.
            toolboxIndex = strfind(filepath, fsep);
            if isempty(toolboxIndex)
                toolboxName = filepath;
            else
                toolboxName = filepath(toolboxIndex(end)+1:end);
            end
        else
            
            % We have 'toolbox' in the path, so we get the next directory
            % name if it exists.  If it does not, 'toolbox' is returned.
            % If the next directory is 'shared', return the following
            % directory unless 'shared' is the parent directory of the
            % calling function.
            
            % Remove everything up to 'toolbox'.
            filepath(1:toolboxIndex-1) = [];

            % Find all the file separators to determine how many
            % directories after 'toolbox' parent this function.
            indx = strfind(filepath, fsep);
            switch numel(indx)
                case 0
                    % If there is nothing after toolbox, return 'toolbox'
                    % as the toolbox name.
                    toolboxName = filepath;
                case 1
                    % If there is a single directory after toolbox, return
                    % it with no additional checks.
                    toolboxName = filepath(indx+1:end);
                otherwise
                    % If the toolbox is shared, and it is not the last
                    % directory in the path, return the next directory,
                    % otherwise return this one, which might be 'shared'.
                    toolboxName = filepath(indx(1)+1:indx(2)-1);
                    if strcmp(toolboxName, 'shared')
                        if numel(indx) > 2
                            toolboxName = filepath(indx(2)+1:indx(3)-1);
                        else
                            toolboxName = filepath(indx(2)+1:end);
                        end
                    end
            end
        end
    end

% -------------------------------------------------------------------------
    function className = getClassName
        
        % Check if there are any object directories in the filepath.
        classIndex = min([findstr(filepath, [fsep '@']) findstr(filepath, [fsep '+'])]);
        if isempty(classIndex)
            className = '';
        else
            
            % Get the object filepath information.
            className = strrep(filepath(classIndex:end), [fsep '@'], ':');
            className = strrep(className, [fsep '+'], ':');
            
            % Strip off the separator and everything after to simplify the
            % string for the getToolboxName function.
            filepath(classIndex:end) = [];
        end
    end

% -------------------------------------------------------------------------
    function functionName = getFunctionName
        
        % Get the function name from the filepath.
        functionIndex = max(strfind(filepath, fsep));
        functionName = filepath(functionIndex+1:end);
        
        % Strip off the separator and everything after to simplify the
        % string for the getClassName function.
        filepath(functionIndex:end) = [];
    end
end

% -------------------------------------------------------------------------
function filepath = getPathFromStack

s = dbstack('-completenames');

% If the stack is only 2 deep, this function was called from the command
% line.  This is not supported.  This is 2 because we are in a subfunction
% of generatemsgid which is 1 up the stack.  We need to be called from a
% function about generatemsgid.
if length(s) == 2
    error(generatemsgid('notCalledFromFunction'), ...
        'GENERATEMSGID must be called from a function.');
end

filepath = s(3).file;

end

% [EOF]
