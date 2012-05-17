function data = computeStdRegTableData(this,ynum)
%Compute what goes into the std regressor ("order") table, as a cell array
% with 4 columns.
% m: handle to the messenger

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:30:48 $

if nargin<2
    ynum = 1;
end

messenger = nlutilspack.getMessengerInstance;
header1 = {'Input Channels','','',''};
header2 = {'Output Channels','','',''};

% Inputs
m = this.NlarxModel;
[ny,nu] = size(m);
unames = messenger.getInputNames; 
ynames = messenger.getOutputNames;
%allnames = [unames;ynames];

data1 = cell(nu,4);
data1(:,1) = unames;
for k = 1:nu
    data1{k,2} = int2str(m.nk(ynum,k));
    data1{k,3} = int2str(m.nb(ynum,k));
    data1{k,4} = nlbbpack.getRegExpr(m,k+1,ynum); %sprintf('u%d(t-1), u%d(t-2)',k,k);
end

data2 = cell(ny,4);
data2(:,1) = ynames;

for k = 1:ny
    data2{k,2} = int2str(1);
    data2{k,3} = int2str(m.na(ynum,k));
    data2{k,4} = nlbbpack.getRegExpr(m,nu+k+2,ynum); %sprintf('y%d(t-1), y%d(t-2)',k,k);
end

data = [header1;data1;header2;data2];
