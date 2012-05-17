function varargout = unrender(h, varargin)
%UNRENDER Unrender the siggui object

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.5 $  $Date: 2004/12/26 22:22:13 $

if isrendered(h),
    
    delete(h.Layout);
    
    % Send the sigguiUnrendering event
    send(h, 'sigguiClosing', handle.EventData(h, 'sigguiClosing'));
    
    h.WhenRenderedListeners = [];
%     delete(convert2vector(h.WhenRenderedListeners));
    
    % Allow subclasses to do whatever rendering they need.
    if nargout,
        [varargout{1:nargout}] = thisunrender(h, varargin{:});
    else
        thisunrender(h, varargin{:});
    end
    
    % Make sure that the GUI is still rendered.  This check safeguards against
    % THISRENDER doing things that result in recursion.
    if isrendered(h),
    
        % Delete the rendered properties
        deleteproperties(h);
    end
end

% ---------------------------------------------------------------------------
function deleteproperties(h)

% hRProps = get(h, 'RenderedPropHandles');

% If hRProps is empty (this was probably caused by an undo operation), just
% find all the properties.
% if isempty(hRProps),
    hRProps = [h.findprop('Visible'), ...
            h.findprop('Enable'), ...
            h.findprop('Layout'), ...
            h.findprop('FigureHandle'), ...
            h.findprop('Handles'), ...
            h.findprop('WhenRenderedListeners'), ...
            h.findprop('RenderedPropHandles'), ...
            h.findprop('BaseListeners'), ...
            h.findprop('Parent'), ...
            h.findprop('Container')];
% end
delete(hRProps);

% [EOF]
