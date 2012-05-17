function sfdig_do_callback(hMenu, eventargs)

% Copyright 2005 The MathWorks, Inc.

    item = get(hMenu, 'userdata');
    item.invokeCallBack;
end