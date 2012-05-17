function b = isspecmet(this, hfdesign, varargin)
%ISSPECMET   True if the object's specification has been met by the filter.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2009/04/21 04:32:08 $

if nargin > 1
    m = measure(this,hfdesign);  
else
    m = measure(this);
end

if isempty(m)
    b = false;
else
    if nargin > 1,
        b = isspecmet(m,hfdesign,varargin{:});
    else
        b = isspecmet(m);
    end
end

% [EOF]
