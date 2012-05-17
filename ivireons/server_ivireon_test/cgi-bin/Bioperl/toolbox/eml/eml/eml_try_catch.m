function [errid,errmsg,varargout] = eml_try_catch(function_name, varargin)
% EML_TRY_CATCH
%
% This function is undocumented and unsupported.  It is needed for the
% correct functioning of your installation.


%EML_TRY_CATCH Embedded MATLAB helper function to use try/catch when constant folding
%
%    [ERRID, ERRMSG, X, Y ...] = eml_try_catch(FUNCTION_NAME, A, B, ... ) fevals
%    the function named in string FUNCTION_NAME with input arguments A, B,
%    etc.  If no error is thrown during the call, then ERRID and ERRMSG will
%    be empty strings, and the return values from the function call are in
%    variables X, Y, etc.  If an error is thrown during the call, then the
%    error identifier is returned in string ERRID, the error message is
%    returned in string ERRMSG, and X, Y, etc. will be empty.

% Copyright 2008-2009 The MathWorks, Inc.

    errid  = '';
    errmsg = '';
    try
        [varargout{1:nargout-2}] = feval(function_name,varargin{:});
    catch me
        errid  = me.identifier;
        
        % This hack is necessary for i18n due to Embedded MATLAB (EML)
        % limitations.  EML only supports 8-bit characters.  It eventually passes the
        % resulting characters through ut_printm ... which expects a 'native'
        % byte-array.  This hack creates a string that when blindly converted to
        % bytes returns the original message. See g553385.
        errmsg = char(unicode2native(me.message));
        varargout = cell(1,nargout-2);
    end

