function varargout = checkClipping(this)
%CHECKCLIPPING Check if the collected data is clipped
%   FLAG = CHECKCLIPPING(H) checks if the data in the eye diagram object H was
%   clipped.

%   @commscope/@eyediagram
%
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/31 23:15:06 $

% Check if there was clipping.  
flag = (sum(sum(this.PrivVerHistRe)) ~= this.PrivSampsProcessed);
if flag 
    if (nargout == 0)
        warning([this.getErrorId ':OutOfRange'], ['The input signal exceeded the '...
            'amplitude limits.  Out-of-range signal values are ignored.  Adjust '...
            'amplitude limits.']);
    else
        varargout{1} = flag;
    end
end

%-------------------------------------------------------------------------------
% [EOF]
