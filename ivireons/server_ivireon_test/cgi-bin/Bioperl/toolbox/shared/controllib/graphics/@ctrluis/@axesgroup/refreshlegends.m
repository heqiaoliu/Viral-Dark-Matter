function refreshlegends(this,varargin)
% REFRESHLEGENDS Refreshes the legends for the axesgroup

%  Author(s): C. Buhr
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:15:35 $

ax = this.Axes2d(:);
ax = ax(ishghandle(ax,'axes'));

if nargin>1
    ax = ax(varargin{1});
end

parent = this.Parent;

% Find all legends
legax = findobj(get(parent,'Children'),'flat','Type','axes','Tag','legend');

% Refresh legends
warn = ctrlMsgUtils.SuspendWarnings;
for ct = 1:length(legax)
    leg = legax(ct);
    if isa(handle(leg),'scribe.legend')
        % Get axes that legend is associated with
        targetax = get(leg,'axes');

        % Check if its a legend for the @axesgroup
        if any(double(targetax)==double(ax(:)))
            if strcmpi(get(targetax,'visible'),'off')
                legend(double(targetax),'off')
            else
                % Refresh legend
%                 methods(handle(leg),'refresh'); 
                loc = get(leg,'location');
                pos = get(leg,'position');
                % Currently to refresh a legend you delete it and refresh it
                legend(double(targetax),'off')
                newleg = legend(double(targetax),'show');
                % adjust position so it does not jump around when legend is
                % updated
                if ~isempty(newleg)
                    if strcmpi(loc,'none')
                        newlegpos = get(newleg,'position');
                        set(newleg,'position',[pos(1),pos(2)+pos(4)-newlegpos(4),newlegpos(3),newlegpos(4)]);
                    else
                        set(newleg,'location',loc);
                    end
                end
            end
        end
    end
end
delete(warn);



