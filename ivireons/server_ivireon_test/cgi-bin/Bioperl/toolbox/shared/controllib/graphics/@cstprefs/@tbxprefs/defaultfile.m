function filename = defaultfile(h)
%DEFAULTFILE  Get name of user's default preference file

%   Author(s): A. DiVergilio
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:13:02 $

filename = [prefdir(1) filesep 'cstprefs.mat'];
