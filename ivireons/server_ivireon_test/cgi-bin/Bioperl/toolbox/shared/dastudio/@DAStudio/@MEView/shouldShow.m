function show = shouldShow(h, obj)

show = true;

% no need to do any work if the view has no properties
if ~isempty(h.Properties)
    % if the object has at least 1 matching property, show it
    matching = find(h.Properties, 'isMatching', true);
    for i = 1:length(matching)
        % TODO: need to account for aliased property names
        show = obj.isValidProperty(matching(i).Name);
        if show
            return;
        end
    end
end