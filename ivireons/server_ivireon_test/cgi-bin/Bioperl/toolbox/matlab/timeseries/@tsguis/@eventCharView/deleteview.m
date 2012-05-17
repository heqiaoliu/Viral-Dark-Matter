function deleteview(this)
%DELETEVIEW  Deletes @view and associated g-objects.

%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2008/12/29 02:11:07 $

%% Overloaded since the call to ghandles in the parent method cannot return
%% the links or the labels

for ct = 1:length(this)
   delete(this(ct).VLines(ishghandle(this(ct).VLines)));
   delete(this(ct).Points(ishghandle(this(ct).Points)));
end

% Delete views
delete(this)
