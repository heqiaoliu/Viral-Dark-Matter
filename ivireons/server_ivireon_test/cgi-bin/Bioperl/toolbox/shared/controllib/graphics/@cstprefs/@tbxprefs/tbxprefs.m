function h_out = tbxprefs
%TBXPREFS  Toolbox preferences object constructor

%   Author(s): A. DiVergilio
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:13:13 $

mlock

persistent h; 
           
if isempty(h)
    %---Create class instance (w/default values)
    h = cstprefs.tbxprefs;
    h.reset;  %---This may not be necessary as of beta5
	      %---Load default user preference file (if it exists)
    h.load;
end

h_out = h;

