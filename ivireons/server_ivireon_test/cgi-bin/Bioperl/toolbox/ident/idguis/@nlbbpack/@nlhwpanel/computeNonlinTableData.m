function data = computeNonlinTableData(this)
% Compute the entries for the nonlinear options table by reading values
% from the model.

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/05/19 23:04:12 $
% Written by Rajiv Singh.

messenger = nlutilspack.getMessengerInstance;
m = this.NlhwModel;
[ny,nu] = size(m);

% Inputs
unames = messenger.getInputNames; 
ynames = messenger.getOutputNames;

header1 = {'Input Channels','','',''};
header2 = {'Output Channels','','',''};

inputdata = cell(nu,4);
unl = m.InputNonlinearity;
for k = 1:nu
    inputdata(k,:) = {unames{k},LocalNLName(unl(k)),LocalNLNumUnits(unl(k)),''};
end

outputdata = cell(ny,4);
ynl = m.OutputNonlinearity;
for k = 1:ny
    outputdata(k,:) = {ynames{k},LocalNLName(ynl(k)),LocalNLNumUnits(ynl(k)),''};
end

data = [header1;inputdata;header2;outputdata];

%--------------------------------------------------------------------------
function str = LocalNLName(NL)

str = nlbbpack.getNlhwNonlinTypes([],class(NL));

%--------------------------------------------------------------------------
function str = LocalNLNumUnits(NL)

switch class(NL)
    case 'wavenet'
        num = NL.NumberOfUnits;
        if ischar(num)
            if strcmpi(num,'auto')
                str = 'Chosen automatically';
            else
                str = 'Chosen interatively during estimation'; 
            end
        else
            str = int2str(num);
        end
    case 'sigmoidnet'
        str = int2str(NL.NumberOfUnits);
    case 'unitgain'
        str = '';
    case {'saturation','deadzone'}
        str = '';
    case 'pwlinear'
        str = int2str(NL.NumberOfUnits);
    case 'poly1d'
        str = int2str(NL.Degree);
    otherwise
        str = '';
end
