function [out, docTopic] = help(varargin)
    %  HELP Display help text in Command Window.
    %     HELP, by itself, lists all primary help topics. Each primary topic
    %     corresponds to a directory name on the MATLABPATH.
    %
    %     HELP / lists a description of all operators and special characters.
    %
    %     HELP FUN displays a description of and syntax for the function FUN.
    %     When FUN is in multiple directories on the MATLAB path, HELP displays
    %     information about the first FUN found on the path.
    %
    %     HELP PATHNAME/FUN displays help for the function FUN in the PATHNAME
    %     directory. Use this syntax to get help for overloaded functions.
    %
    %     HELP MODELNAME.MDL displays the complete description for the MDL-file
    %     MODELNAME as defined in Model Properties > Description. If Simulink
    %     is installed, you do not need to specify the .mdl extension.
    %
    %     HELP DIR displays a brief description of each function in the MATLAB
    %     directory DIR. DIR can be a relative partial pathname (see HELP
    %     PARTIALPATH). When there is also a function called DIR, help for both
    %     the directory and the function are provided.
    %
    %     HELP CLASSNAME.METHODNAME displays help for the method METHODNAME of
    %     the fully qualified class CLASSNAME. To determine CLASSNAME for
    %     METHODNAME, use CLASS(OBJ), where METHODNAME is of the same class as
    %     the object OBJ.
    %
    %     HELP CLASSNAME displays help for the fully qualified class CLASSNAME.
    %
    %     HELP('syntax') displays help describing the syntax used in MATLAB
    %     commands and functions.
    %
    %     T = HELP(TOPIC) returns the help text for TOPIC as a string, with
    %     each line separated by \n. TOPIC is any allowable argument for HELP.
    %
    %     REMARKS:
    %     1. Use MORE ON before running HELP to pause HELP output after a
    %     screenful of text displays.
    %     2. In the help syntax, function names are capitalized to make them
    %     stand out. In practice, always type function names in lowercase. For
    %     functions that are shown with mixed case (for example, javaObject)
    %     type the mixed case as shown.
    %     3. Use DOC FUN to display help about the function in the Help
    %     browser, which might provide additional information, such as graphics
    %     and more examples.
    %     4. Use DOC HELP for information about creating help for your own
    %     M-files.
    %     5. Use the Help browser search field to find more information 
    %     about TOPIC or other terms.
    %
    %     EXAMPLES:
    %     help close - displays help for the CLOSE function.
    %     help database/close - displays help for the CLOSE function in the
    %     Database Toolbox.
    %     help database - lists all functions in the Database Toolbox and
    %     displays help for the DATABASE function.
    %     help general - lists all functions in the directory MATLAB/GENERAL.
    %     help f14_dap - displays the description of the Simulink f14_dap.mdl
    %     model file (Simulink must be installed).
    %     t = help('close') - gets help for the function CLOSE and stores it as
    %     a string in t.
    %
    %     See also DOC, DOCSEARCH, HELPBROWSER, HELPWIN, LOOKFOR, MATLABPATH,
    %     MORE, PARTIALPATH, WHICH, WHOS, CLASS.

    %   Copyright 1984-2007 The MathWorks, Inc.
    %   $Revision: 1.1.6.33 $  $Date: 2010/04/21 21:32:13 $

    if nargin && ~iscellstr(varargin)
        error('MATLAB:help:NotAString', 'Argument to help must be a string.');
    end

    % clear/initialize the directory hashtable
    helpUtils.hashedDirInfo;
    
    process = helpUtils.helpProcess(nargout, nargin, varargin);

    try
        process.getHelpText;
        
        process.prepareHelpForDisplay;
        
        % clear the directory hashtable
        % ignore error cases, as it will be cleared upon the next call to help
        helpUtils.hashedDirInfo;
    catch e %#ok<NASGU>
        % no need to tell customers about internal errors
    end

    if nargout > 0
        out = process.helpStr;
        if nargout > 1
            docTopic = process.docTopic;
        end
    end
end
