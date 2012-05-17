function Bounds = getBounds(this)
%getBounds  Data update method for bounds

%   Author(s): Craig Buhr
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/26 17:49:34 $

if isempty(this.Bounds) || isempty(this.Bounds.UpperAmplitudeBound)
    computeBounds(this)
end

Bounds = this.Bounds;


