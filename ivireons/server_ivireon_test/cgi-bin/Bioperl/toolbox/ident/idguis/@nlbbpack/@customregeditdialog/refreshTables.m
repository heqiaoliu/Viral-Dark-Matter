function refreshContents(this)
% refresh the one-at-atime and batch mdoel tables to refrect the current
% I/O variables

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:30:27 $

messenger = nlutilspack.messenger;
unames = messenger.getInputNames;
ynames = messenger.getOutputNames;
names = [unames; ynames];

descr = cell(length(names),1);
for k = 1:length(unames)
    descr{k} = ['Input ',int2str(k)];
end

for k = 1:length(ynames)
    descr{k+length(unames)} = ['Output ',int2str(k)];
end

tabledata  = [names;descr];