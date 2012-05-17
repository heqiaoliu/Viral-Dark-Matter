function tfldesigner(varargin)

%   Copyright 2009-2010 The MathWorks, Inc.

daRoot = DAStudio.Root;
me = daRoot.find('-isa', 'TflDesigner.explorer');

if length(me) > 1
    for i = length(me)
        if ~me(i).isVisible
            delete(me(i));
        end
    end
end

if ~isempty(me) && ~me.isVisible
    delete(me);
end

mlock;
if isempty(me)
    if ~isempty(varargin)
        td = TflDesigner.explorer(varargin);
    else
        td = TflDesigner.explorer;
    end
else
    td = TflDesigner.getexplorer;
    if ~isempty(varargin)
        me.setStatusMessage('Busy');
        rt = me.getRoot;
        rt.populate(varargin);
        me.setStatusMessage('Ready');
    end
end

td.show;
