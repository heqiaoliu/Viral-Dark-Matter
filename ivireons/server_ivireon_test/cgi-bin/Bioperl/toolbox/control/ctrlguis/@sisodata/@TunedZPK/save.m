function Design = save(this,Design)
%SAVE   Creates backup of compensator data.

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2005/12/22 17:39:42 $

if nargin == 1
    Design = sisodata.TunedZPKSnapshot;
end

Design = utStoreTunedZPK(Design,this);