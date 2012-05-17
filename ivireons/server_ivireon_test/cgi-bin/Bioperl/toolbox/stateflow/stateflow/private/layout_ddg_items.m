function container = layout_ddg_items(container, layout)

% Copyright 2005-2008 The MathWorks, Inc.

[rows, cols] = size(layout);
container.LayoutGrid = [rows, cols];

items = [];
tags = {};
for row = 1:rows
    for col = 1:cols
        item = layout{row,col};
        if ~isempty(item)
            % The tag needs to be escaped because the tags returned by
            % the data type widget generator contain the non-alphanumeric
            % character '|'
            tag = escape_tag(item.Tag);
            if isfield(items, tag)
                item = items.(tag);
            else
                item.RowSpan = [rows 1];
                item.ColSpan = [cols 1];
            end
            item.RowSpan = [min(item.RowSpan(1), row) max(item.RowSpan(2), row)];
            item.ColSpan = [min(item.ColSpan(1), col) max(item.ColSpan(2), col)];
            items.(tag) = item;
            tags{end+1} = tag;
        end
    end
end

container.Items = {};
for i = 1:length(tags)
    item = items.(tags{i});
    if ~isempty(item)
        container.Items{end+1} = item;
        items.(tags{i}) = [];
    end
end

% Escape non-alphanumeric characters with '_'
function escaped_tag = escape_tag(tag)

escaped_tag = regexprep(tag, '\W', '_');
