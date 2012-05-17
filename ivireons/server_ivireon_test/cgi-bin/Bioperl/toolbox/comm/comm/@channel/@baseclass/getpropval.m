function val = getpropval(h, prop);
%GETPROPVAL Generalized get method for objects.
%   GETPROPVAL(H, 'prop') is equivalent to GET(H, 'prop').
%   GETPROPVAL(H, 'obj.prop') is equivalent to GET(GET(H, 'obj'), 'prop').
%   That is, this latter syntax is thus used to get to properties of
%   component objects without using the H.obj.prop syntax.

% Copyright 2004 The MathWorks, Inc.

done = false;
while (~done)
    [propName, remProps] = strtok(prop, '.');
    val = get(h, propName);
    done = isempty(remProps);
    if (~done)
        % val is component object.
        h = val;
        prop = remProps;
    end
end
    

