function out = clipboard(whatToDo, stuff)
%CLIPBOARD Copy and paste strings to and from system clipboard.
%
%   CLIPBOARD('copy', STUFF) Sets the clipboard contents to STUFF.  If STUFF
%   is not a char array, MAT2STR is used to convert it to a string.
%
%   STR = CLIPBOARD('paste') Returns the current contents of the clipboard as
%   a string or '' if the current clipboard cannot be converted to a string.
%
%   DATA = CLIPBOARD('pastespecial') Returns the current contents of the
%   clipboard as an array using UIIMPORT.
%
%   Note: CLIPBOARD requires Java on all platforms.
% 
%   Example:
%       clipboard('copy', 'this has been copied');
%       str = clipboard('paste');
%       data = clipboard('pastespecial');
%   
%   See also LOAD, FILEFORMATS, UIIMPORT

% Copyright 1984-2006 The MathWorks, Inc.
% $Revision: 1.14.4.8 $  $Date: 2007/09/27 22:47:54 $

err = javachk('awt', 'Clipboard access');
if ~isempty(err)
    error('MATLAB:clipboard:UnsupportedPlatform', err.message);
end

error(nargchk(1,2,nargin));
error(nargchk(0,1,nargout));

if strcmpi(whatToDo, 'copy')
    if nargin == 1
        error('MATLAB:clipboard:InsufficientCopyArguments',...
            'The CLIPBOARD function requires two input arguments when copying.');
    end

    if isempty(stuff)
        return;
    end
    
    
    if ischar(stuff)
        if size(stuff, 1) > 1
            % This is a buffered array of vertically cat'd "strings."
            % In this case, we have no idea of how to "glue" the
            % "strings" together.  (Do we cat them with ASCII 10's?
            % 13/10 pairs?  Per platform?  Just combine them with no
            % return-style character between them?  Or what?
            % Since whatever we do is likely to be wrong, let's not try
            % to guess.
            error('MATLAB:clipboard:MultiLineString', ...
                ['The second argument to the CLIPBOARD function cannot ' ...
                 'be a multi-line character array.'])
        end
    else
        % this should error out if something is hokey
        stuff = mat2str(stuff);
    end

    % create ClipboardHandler object
    cpobj = com.mathworks.page.utils.ClipboardHandler;

    % do the copy
    cpobj.copy(stuff);
elseif strcmpi(whatToDo, 'paste')
    % create ClipboardHandler object
    cpobj = com.mathworks.page.utils.ClipboardHandler;

    % do the paste
    out = char(cpobj.paste);

    % check for error (possibly false errors???)
    if strcmp(out, '!ERR#')
        
        out = '';
    end
elseif strcmpi(whatToDo, 'pastespecial')
    % given output arg, get results from uiimport and hand off
    % otherwise, let uiimport think it was called from the caller's wksp
    if nargout
        out = uiimport('-pastespecial');
    else
        evalin('caller', 'uiimport(''-pastespecial'');');
    end
else
    error('MATLAB:clipboard:IncorrectUsage', ...
        'Usage: CLIPBOARD(''copy'',stuffToCopy) or OUT = CLIPBOARD(''paste'')')
end
