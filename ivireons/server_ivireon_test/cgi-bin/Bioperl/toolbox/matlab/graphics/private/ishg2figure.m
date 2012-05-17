function yup = ishg2figure(fig)
% Return TRUE if FIG contains any HG2 graphics.
%
% NOTE: Eventually, this helper file will be obsolete and should be deleted.

% Copyright 2006 The MathWorks, Inc.
    
    viewer = getappdata(fig,'hg2peer');
    
    if isempty(viewer)
        yup = false;
    else
        yup = true;
    end
