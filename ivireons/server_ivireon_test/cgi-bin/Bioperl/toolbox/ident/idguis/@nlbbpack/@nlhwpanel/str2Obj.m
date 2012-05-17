function nlobj = str2Obj(this,str)
% convert string from nl type combo of nonlinear settings panel and return
% a valid object for it.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/05/19 23:04:16 $

switch lower(str(1:3))
    case 'wav'
        nlobj = wavenet('NumberOfUnits','auto');
        %this.WavenetObject = nlobj;
    case 'sig'
        nlobj = sigmoidnet('NumberOfUnits',10);
    case 'sat'
        nlobj = saturation;
    case 'dea'
        nlobj = deadzone;
    case {'uni','non'}
        nlobj = unitgain;
    case 'pie'
        nlobj = pwlinear('NumberOfUnits',10);
    case {'pol','one'}
        nlobj = poly1d('Degree',2);
    case 'cus'
        nlobj = customnet;
    otherwise
        nlobj = [];
        disp('Unknown nonlinearity option for IDNLHW.')
end