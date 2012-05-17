function cleartip(this)
%CLEARTIP  Clears data tip for all view objects.
 
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:28:58 $
for dv=this(:)'
   dv.addtip('');
end