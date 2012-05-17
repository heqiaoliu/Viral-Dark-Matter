function b = applywindow(this,b,N)
%APPLYWINDOW   

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/10/14 16:29:43 $

w = this.Window;
msg = 'Invalid window.';
if ~isempty(w),
    if isa(w, 'function_handle') || ischar(w),
        try
            w = feval(w,N+1);
        catch
            error(generatemsgid('InvalidWindow'),msg);
        end
    elseif iscell(w) && length(w)==2,
        try
            w = feval(w{1},N+1,w{2});
        catch
            error(generatemsgid('InvalidWindow'),msg);
        end
    elseif isnumeric(w)
        if length(w)~=N+1,
            error(generatemsgid('InvalidWindow'),msg);
        end
    else
        error(generatemsgid('InvalidWindow'),msg);
    end
    b = b.*w(:).';
end


% [EOF]
