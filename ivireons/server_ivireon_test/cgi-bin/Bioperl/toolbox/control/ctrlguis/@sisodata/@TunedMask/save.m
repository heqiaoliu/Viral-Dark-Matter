function Design = save(this,Design)
%SAVE   Creates backup of compensator data.

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2006/01/26 01:46:16 $

if nargin == 1
    Design = sisodata.TunedMaskSnapshot;
end

Design = utStoreTunedMask(Design,this);