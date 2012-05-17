function str = getDatatipText(this,dataCursor)

% Copyright 2003-2004 The MathWorks, Inc.

ind = dataCursor.dataIndex;
str = {['X= ' num2str(this.xdata(ind))], ...
       ['Y= ' num2str(this.ydata(ind))]};
