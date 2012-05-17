function i = binsearch(x,v)

n = int32(numel(x));
left = int32(1);
right = n;

while left < right
    middle = (left + right) / 2;
    pv = x(middle);
    if v < pv
        right = middle - 1;
    elseif v > pv
        left = middle + 1;
    else
        i = middle;
        return
    end
end
if left > 0 && left <= n && x(left) == v
    i = left;
else
    i = 0; % Not found
end
