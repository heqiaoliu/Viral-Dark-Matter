function hilite(url)
% HILITE Hilite object corresponding to Simulink URL
    
%   Copyright 2009 The MathWorks, Inc.
%   $Revision $ $Date $

h = Simulink.URL.parseURL(url);
h.hilite;
