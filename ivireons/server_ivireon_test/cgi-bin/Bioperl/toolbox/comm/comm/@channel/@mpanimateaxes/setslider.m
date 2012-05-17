function setslider(h, sliderObj);
%SETSLIDER  Slider callback for multipath axes object.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:20:10 $

N = get(sliderObj, 'value');
h.MaxNumSnapshots = round((100-N) + 1);