function result = is_eml_chart(chartIds)

% Copyright 2002 The MathWorks, Inc.

result = false(1,numel(chartIds));

for i = 1:numel(chartIds)
    t = sf('get',chartIds(i),'chart.type') == 2;
    if ~isempty(t) && t
        result(i) = true;
    end
end
