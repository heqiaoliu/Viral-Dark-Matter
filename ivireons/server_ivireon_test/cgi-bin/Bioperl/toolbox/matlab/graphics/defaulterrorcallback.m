function defaulterrorcallback(h, evt)
% The default value for ErrorCallback properties.

%   Copyright 2009 The MathWorks, Inc.
evt = prepareEvt(evt,h);
msg = prepare_message(evt.error.message, evt.error.cause);
warning(evt.error.id, msg);
end

function evt = prepareEvt(evt,h)

k = evt.error;

while (~isempty(k))
    
    if(strcmp(k.id,'MATLAB:HG2:SceneNode'))
        try
            k.message = ['Error updating ' h.type '. Following is the chain of causes of the error:\n'];
        catch e
            k.message = 'Error updating a graphics object. Following is the chain of causes of the error:\n';
        end
    end
    
    if(strcmp(k.id, 'MATLAB:HG2:Property'))
        mssg = '';
        mssg1 = '';
        if ~isempty(k.message)
            mssg1 = k.message;
        end
        m = size(k.Properties, 2);
        for i=1:m
            try
                s = sprintf(' <a href="matlab:helpview([docroot,''/techdoc/ref/%s_props.html#%s''])">%s</a>', h.type, k.Properties{i},k.Properties{i});
            catch e
                s = k.Properties{i};
            end
            if(i==m)
                mssg = [mssg s];
            else
                mssg = [mssg s ', '];
            end
        end
        k.message = [mssg1 ' Error in one or more of the following properties: \n' mssg];
    end
    k = k.Cause;
    
end

end


function dstmsg = prepare_message(srcmsg, cause)

if isempty(cause)
    dstmsg = srcmsg;
else
    tmpmsg = [srcmsg '\n ==> ' cause.message '\n'];
    dstmsg = prepare_message(tmpmsg, cause.cause);
    
end
end

