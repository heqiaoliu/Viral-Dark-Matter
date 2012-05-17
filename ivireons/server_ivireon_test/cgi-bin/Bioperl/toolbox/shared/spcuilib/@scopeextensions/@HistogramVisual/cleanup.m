function cleanup(this,hVisParent)
% CLEANUP Cleanup the visuals' HG components.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $    $Date: 2010/03/31 18:41:25 $

if ~(this.NTXFeaturedOn)
    % Reset the ResizeFcn
    set(hVisParent, 'ResizeFcn','');
end
cleanupAxes(this,hVisParent);



