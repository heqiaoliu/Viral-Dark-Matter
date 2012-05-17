function data = computeLinearTableData(this,ynum)
%Compute what goes into the linear ("orders") table, as a cell array
% with 4 columns, for output number ynum (default 1).

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/02/06 19:52:06 $

if nargin<2
    ynum = 1;
end

messenger = nlutilspack.getMessengerInstance;

% Inputs
unames = messenger.getInputNames; 
data(:,1) = unames;
m = this.NlhwModel;
for k = 1:length(unames)
    data{k,2} = int2str(m.nb(ynum,k));
    data{k,3} = int2str(m.nf(ynum,k));
    data{k,4} = int2str(m.nk(ynum,k));
end
