function s = getsize(this)
%GETSIZE  Returns grid size required for plotting data. 

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:20:53 $
if isempty(this.HSV)
   s = [0 0];
else
   s = [1 1];
end