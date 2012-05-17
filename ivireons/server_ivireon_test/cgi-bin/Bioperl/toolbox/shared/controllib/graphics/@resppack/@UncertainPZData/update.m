function update(this,r)
%UPDATE  Data update method @UncertainTimeData class

%   Author(s): Craig Buhr
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/05/10 17:37:26 $


for ct=1:length(wchar.Data)
   % Propagate exceptions
   this.Data(ct).Exception = r.Data(ct).Exception;
   if ~this.Data(ct).Exception
      getUncertainPZData(r.DataSrc,r,this.Data,[],[]);
   end
end

