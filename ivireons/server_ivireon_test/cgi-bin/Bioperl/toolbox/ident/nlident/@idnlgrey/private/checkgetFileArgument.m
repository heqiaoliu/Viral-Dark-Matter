function [errmsg, FileArgument] = checkgetFileArgument(varargin)
%CHECKGETFILEARGUMENT  Iterates through a list of property value pairs in
%   order to find and check FileArgument. PRIVATE FUNCTION.
%
%   [ERRMSG, FILEARGUMENT] = CHECKGETFILEARGUMENT(VARARGIN);
%
%   VARARGIN is a list of property value pairs.
%
%   ERRMSG is either '' or a non-empty string specifying the first error
%   encountered during FileArgument checking.
%
%   FILEARGUMENT is set to the value of FileArgument if this is present in
%   the list of properties. Otherwise FileArgument is set to {}.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.10.3 $ $Date: 2008/12/04 22:34:50 $
%   Written by Peter Lindskog.

% Initialize FileArgument and errmsg.
FileArgument = {};
errmsg = '';

% Determine FileArgument.
arg = varargin;
for i = 1:2:length(arg)
    if ischar(arg{i})
        if (length(strmatch(lower(arg{i}), 'fileargument')) == 1)
            try
                FileArgument = arg{i+1};
                if ~iscell(FileArgument)
                    ID = 'Ident:idnlmodel:idnlgreyFileArg1';
                    msg = ctrlMsgUtils.message(ID);
                    errmsg = struct('identifier',ID,'message',msg);
                end
            catch
                ID = 'Ident:idnlmodel:idnlgreyFileArg2';
                msg = ctrlMsgUtils.message(ID);
                errmsg = struct('identifier',ID,'message',msg);
            end
            return;
        end
    end
end