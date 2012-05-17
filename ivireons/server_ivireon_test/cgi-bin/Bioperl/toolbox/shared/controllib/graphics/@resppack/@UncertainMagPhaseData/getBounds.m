function Bounds = getBounds(this)
%getBounds  Data update method for bounds

%   Author(s): Craig Buhr
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/05/10 17:37:21 $

if isempty(this.Bounds) || isempty(this.Bounds.UpperMagnitudeBound)
    computeBounds(this)
end

Bounds = this.Bounds;


