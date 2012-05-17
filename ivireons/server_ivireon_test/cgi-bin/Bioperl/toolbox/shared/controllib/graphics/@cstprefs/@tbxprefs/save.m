function save(h,filename)
%SAVE  Save Toolbox Preferences to disk

%   Author(s): A. DiVergilio
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:13:10 $

if nargin<2
   %---If no file name is specified, save to default preference file
   filename = h.defaultfile;
end

%---We need to save the preferences in structure 'p'
p = get(h);

%---Write preferences to disk
save(filename,'p');
