function util_gen_warning_notrace(warningId, varargin)

%   Copyright 2009 The MathWorks, Inc.

    wstate = warning('backtrace');
    warning('backtrace','off');         
    warning(warningId, varargin{1:end})
    warning('backtrace', wstate.state);   
end

