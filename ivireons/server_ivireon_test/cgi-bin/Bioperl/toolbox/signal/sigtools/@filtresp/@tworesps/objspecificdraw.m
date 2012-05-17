function objspecificdraw(this)
%OBJSPECIFICDRAW   Perform the tworesps specific drawing.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/12/26 22:19:02 $

h = get(this, 'Handles');

if length(this.Filters) == 1 && ...
        ~(showpoly(this.FilterUtils) && ispolyphase(this.Filters(1).Filter))
    if isa(this.Filters(1).Filter, 'dfilt.abstractsos')&& ~isempty(this.SOSViewOpts)
        if ~strcmpi(this.SOSViewOpts.View, 'complete')
            return;
        end
    end
    le = length(h.cline);
    if le ~= 1,
        c = getcolorfromindex(h.axes(1), 2);
        set(getline(this.Analyses(2)), 'Color', c, ...
            'MarkerFaceColor', c);
    end
end

% [EOF]
