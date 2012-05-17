function [list,defaultindex]=getmacprinters
%GETMACPRINTERS Lists Mac OS X printers and the default.
%
%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.1.10.2 $  $Date: 2006/06/27 23:04:08 $


    [fail,w] = unix('lpstat -a | grep -v "not accepting" | sed -e ''s/ accepting requests.*//''');
    if fail
        list = {};
        defaultindex = 0;
    else
        list = strread(w, '%s');
        [fail, w] = unix('lpstat -d | sed -e ''s/system default destination: //''');
        
        if fail
            defaultindex = 0;
        else
            w(end) = ''; % strip trailing CR
            defaultindex = find(strcmp(list, w));
            if (isempty(defaultindex))
                defaultindex = 0;
            end
        end
    end
