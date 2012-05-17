function setUID(this,varargin) 
% SETUID  method to create unique identifier for constraint
%
 
% Author(s): A. Stothert 24-May-2006
% Copyright 2006-2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:57 $
   
for ct = 1:numel(this)
   if numel(varargin) < 1
      %Construct new unique ID
      this(ct).uID = sprintf('%s/%s',class(this(ct)), datestr(cputime,30));
   else
      %Use passed IDs
      if iscell(varargin{1})
         this(ct).uID = varargin{1}{ct};
      else
         this(ct).uID = varargin{1};
      end
   end
end