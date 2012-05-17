function recordtxt(h,TextType,Text)
%RECORDTXT  Records text into the @recorder object.

%   Author: P. Gahinet  
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:16:32 $

switch lower(TextType)
case 'history'
    h.EventRecorder.add2hist(Text);
case 'commands'
    
end