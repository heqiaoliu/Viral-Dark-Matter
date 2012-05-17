function handled = eventHandler(h, eventType, obj)

%   Copyright 2010 The MathWorks, Inc.

handled = false;

switch eventType
    case 'TreeSelectionChanged'
        % Decide domain here.
        h.ActiveDomainName = h.getDomainString(obj);
        if strcmp(h.SuggestionMode, 'auto')
            % Switch views if auto switch is on
            [suggestedView reason] = h.getSuggestedView();
            if ~isempty(suggestedView)
                if ~strcmp(suggestedView.Name, h.ActiveView.Name)
                    h.ActiveView = suggestedView;
                    handled = true;
                end
            end
        end
    otherwise
        handled = false;
end