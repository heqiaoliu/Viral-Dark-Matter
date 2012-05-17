function translate(varargin)
%
% Translate strings that could not be easily translated in the C++ mex file
%
% Copyright 2007 The MathWorks, Inc.
%

% Verify number of arguments
if(length(varargin) < 3)
    msg = sprintf('translate() called with %d arguments', length(varargin));
    error_msg(msg);
    return;
end

% First argument should be the translation submethod
method = varargin{1};
if(~ischar(method))
    error_msg('translate() first argument must be a method string');
end
switch(method)
    case 'set_hg_tooltip',
        hgHandle = varargin{2};         
        if(~ishandle(hgHandle))
            error_msg('translate() second argument must be an HG handle');
            return;
        end
        
        % String needing translation. Example: 'Foobar = %d * %s'
        string = varargin{3};          
        if(~isa(string, 'char'))
            error_msg('translate() third argument must be a string to translate');
            return;        
        end
        
        % Assuming varargin{4:end} contains N strings/numbers etc. that can
        % fill slots (such as %s) in string. 
        % NOTE: this works even if varargin = 3
        translatedString = sprintf(xlate(string), varargin{4:end});
        sf_hg_set(hgHandle, 'Tooltip', translatedString);
        
    otherwise,
        msg = sprintf('translate() called with invalid translate method: %s', method);
        error_msg(msg);
        return;
end

function error_msg(str)
    disp(str);


