function hdl=javaaddlistener(jobj, eventName, response)
%  ADDLISTENER Add a listener to a Java object.
%
%  L=ADDLISTENER(JObject, EventName, Callback)
%  Adds a listener to the specified Java object for the given 
%  event name. The listener will stop firing when the return
%  value L goes out of scope.
%
%  ADDLISTENER(JObject)
%  Lists all the available event names.
%
%  Examples:
%
%  jf = javaObjectEDT('javax.swing.JFrame');
%  addlistener(jf) % list all events
%
%  % Basic string eval callback:
%  addlistener(jf,'WindowClosing','disp closing')
%
%  % Function handle callback
%  addlistener(jf,'WindowClosing',@(o,e) disp(e))

% Copyright 2003-2007 The MathWorks, Inc.

% make sure we have a Java objects
if ~isjava(jobj)
    error('MATLAB:addlistener:invalidinput','First input must be a java object')
end
if nargin == 1
    if nargout
        error('MATLAB:addlistener:invalidinput','Outputs not supported with only one input arg')
    end
    % just display the possible events
    hSrc = handle(jobj,'callbackproperties');
    allfields = sortrows(fields(set(hSrc)));
    for i = 1:length(allfields)
        fn = allfields{i};
        if ~isempty(findstr('Callback',fn))
            fn = strrep(fn,'Callback','');
            disp(fn)
        end
    end
    return;
end

hdl = handle.listener(handle(jobj), eventName, ...
    @(o,e) cbBridge(o,e,response));
end

function cbBridge(o,e,response)
    hgfeval(response, java(o), e.JavaEvent)
end
