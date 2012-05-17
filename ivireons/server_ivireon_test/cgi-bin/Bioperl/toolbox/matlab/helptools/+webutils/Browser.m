classdef (Hidden=true) Browser
% BROWSER provides an M wrapper for Java web browsers.
% This wrapper can be used to make JavaScript calls from MATLAB to a web
% browser, as well as make simple DOM modifications to the document
% displayed in the browser.
% This class is unsupported and may change at any time.

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $

    properties (Access=private, Hidden=true)
        BrowserHandle;
    end
    
    methods
        function obj = Browser(browserArg)
            % Constructs a browser wrapper.
            % The argument passed to this constructor should be a Java
            % class that implements the
            % com.mathworks.mlwidgets.html.HTMLCallbackProvider interface.
            if isnumeric(browserArg)
                obj.BrowserHandle = com.mathworks.mlwidgets.html.HTMLCallbackRegistry.getHTMLRenderer(browserArg);
            elseif isjava(browserArg) && isa(browserArg, 'com.mathworks.mlwidgets.html.HTMLCallbackProvider')
                obj.BrowserHandle = browserArg;
            else
                error('MATLAB:webutils:InvalidBrowser', 'Invalid argument to the Browser constructor.');
            end
        end
        
        function setCurrentLocation(obj, location)
            % Loads a page in the browser.
            obj.BrowserHandle.setCurrentLocation(location);
        end
        
        function setHtmlText(obj, text)
            % Displays the HTML text in the browser.
            obj.BrowserHandle.setHtmlText(text);
        end
        
        function result = canExecuteScripts(obj)
            % Indicates whether the browser can execute JavaScript.
            result = obj.BrowserHandle.canExecuteScripts;
        end
        
        function result = canModifyDom(obj)
            % Indicates whether it is possible to perform DOM manipulation.
            result = obj.BrowserHandle.canModifyDom;
        end
        
        function result = javascript(obj, script)
            % Executes JavaScript in the browser.
            % This method optionally returns the return value of the 
            % JavaScript call as a character array.
            script = webutils.Browser.escapeJavaScript(script);
            if nargout > 0
                result = char(obj.BrowserHandle.executeScriptWithReturn(script));
            else
                obj.BrowserHandle.executeScript(script);
            end
        end
        
        function result = getElementText(obj, id)
            % Returns the text contained in an HTML element as a character
            % array.
            result = char(obj.BrowserHandle.getElementText(id));
        end
        
        function setElementText(obj, id, text)
            % Modifies the contents of an HTML element.
            obj.BrowserHandle.setElementText(id, text);
        end
        
        function html = getHtmlText(obj)
            % Returns the HTML source of the current document.
            html = char(obj.BrowserHandle.getHtmlText);
        end
        
        function loc = getCurrentLocation(obj)
            % Returns the location of the current document.
            loc = char(obj.BrowserHandle.getCurrentLocation);
        end
    end
    
    methods (Static, Access=private)
        function script = escapeJavaScript(script)
            % Escapes a MATLAB character array for use within JavaScript.
            script = regexprep(script,'\n','\\n');
        end
    end
end