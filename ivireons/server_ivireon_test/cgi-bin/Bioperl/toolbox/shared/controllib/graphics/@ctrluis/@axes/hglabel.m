function hlabel = hglabel(h,LabelType)
%HGLABEL  Returns handle(s) of visible HG labels of a given type.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:14:39 $

hlabel = get(getaxes(h),LabelType);
