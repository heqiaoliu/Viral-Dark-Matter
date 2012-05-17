function storedValue = getFigureCallback(hThis,hFig,propName)
% Gets the (undocumented) property of the figure.

% Copyright 2006-2007 The MathWorks, Inc.

% This function is only suppored with java figures
if ~usejava('awt')
    storedValue = [];
    return;
end

%Disable the JavaFrame warning:
[ lastWarnMsg lastWarnId ] = lastwarn; 
oldstate = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame'); 

javaFrame = handle(get(hFig,'JavaFrame'));

% Restore the warning state:
warning(oldstate);
lastwarn(lastWarnMsg,lastWarnId);

if isempty(javaFrame)
    storedValue = [];
    return;
end
axisComponent = javaFrame.getAxisComponent;
axisComponentCallbacks = handle(axisComponent, 'callbackproperties');
% All properties are set on the axis component
storedValue = get(axisComponentCallbacks,propName);