function Model = createDefaultModel(this)
% create a default idnlarx model

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:30:49 $

m = nlutilspack.getMessengerInstance;
unames = m.getInputNames;
ynames = m.getOutputNames;

na = 2*eye(length(ynames));
nk = ones(length(ynames),length(unames));
nb = 2*nk;
nl = 'wavenet'; %char(this.jMainPanel.getCurrentNonlinID); %all nl are wavenets in the beginning

Model = idnlarx([na nb nk],nl,'uname',unames,'yname',ynames);
