function display_sf_object(obj)

if (isscalar(obj))
    % omit the semicolon to trigger display
    get(obj)
else
    builtin('disp', obj);
end
