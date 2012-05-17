function ecode = isgfvector(Vec)
% ISVECTOR returns 1 for vector inputs.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/08/20 16:22:31 $

   if(ndims(Vec) == 2)
      if(all([size(Vec,1)>1 size(Vec,2)>1]))
         ecode = 0; % Matrix
      else
         ecode = any([size(Vec,1)>1 size(Vec,2)>1]);
      end;
   else
      ecode = 0;
   end;
return;
