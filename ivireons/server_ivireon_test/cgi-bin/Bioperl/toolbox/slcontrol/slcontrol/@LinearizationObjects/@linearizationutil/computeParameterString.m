function strvalue = computeParameterString(this,val,prec)
% COMPUTEPARAMETERSTRING  Write the parameter value according to class type
%
 
% Author(s): John W. Glass 17-Nov-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2005/12/22 19:06:39 $

%% Write the parameter value according to class type
switch class(val)
    case 'double'
        strvalue = LocalMat2Str(val,prec);
    case 'char'
        strvalue = val;
    case 'ss'
        [A,B,C,D] = ssdata(val);
        strvalue = sprintf('ss(%s,%s,%s,%s,%s)',LocalMat2Str(A,prec),...
            LocalMat2Str(B,prec),LocalMat2Str(C,prec),...
            LocalMat2Str(D,prec),LocalMat2Str(val.Ts,prec));
    case 'tf'
        [num,den] = tfdata(val,'v');
        strvalue = sprintf('tf(%s,%s,%s)',LocalMat2Str(num,prec),...
            LocalMat2Str(den,prec),LocalMat2Str(val.Ts,prec));
    case 'zpk'
        [z,p,k] = zpkdata(val,'v');
        strvalue = sprintf('zpk(%s,%s,%s,%s)',LocalMat2Str(z,prec),...
            LocalMat2Str(p,prec),LocalMat2Str(k,prec),...
            LocalMat2Str(val.Ts,prec));
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function valout = LocalMat2Str(valin,prec)

if isnan(prec)
    valout = mat2str(valin);
else
    valout = mat2str(valin,prec);
end