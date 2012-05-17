function Model = createDefaultModel(this)
% Create a default idnlhw model

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/05/19 23:04:13 $

m = nlutilspack.getMessengerInstance;
unames = m.getInputNames;
ynames = m.getOutputNames;

nk = ones(length(ynames),length(unames));
nb = 2*nk;
nf = nb+1;

nl = 'pwlinear'; 

Model = idnlhw([nb nf nk],nl,nl,'uname',unames,'yname',ynames);
