function cThis = clone(this) 
% CLONE  deep copy of object
%
 
% Author(s): A. Stothert 17-Aug-2007
%   Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:12 $

for ct=numel(this):-1:1
   cThis(ct)        = copy(this(ct));                        
   cThis(ct).Name   = sprintf('Copy of %s',this(ct).Name);   
   if ~isempty(this(ct).Source)
      cThis(ct).Source = copy(this(ct).Source);              
   end
   cThis(ct).Data  = copy(this(ct).Data);                    
   cThis(ct).UID = srorequirement.utGetUID;                 
end



