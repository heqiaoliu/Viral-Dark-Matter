function updateZPK(this)
% UPDATEZPK Calculates the zpk representation from the parameters

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2009/11/09 16:22:20 $

if iscell(this.Par2ZpkFcn)
    [zpkTuned,zpkFixed] = feval(this.Par2ZpkFcn{1},this.Parameters,this.Par2ZpkFcn{2:end});
else
    [zpkTuned,zpkFixed] = this.Par2ZpkFcn(this.Parameters);
end
this.zpkdata = getPrivateData(localConvertTs(this,zpkTuned*zpkFixed));


%%
function zpkdata = localConvertTs(this,zpkdata)

Ts = this.Ts;
TsOrig = this.TsOrig;

if ~isequal(Ts,TsOrig)
    if isequal(Ts,0)
        %d2c
        p = d2cOptions;
        if numel(this.D2CMethod)==1
            p.Method = this.D2CMethod{1};
        else
            p.Method = 'tustin';
            p.PrewarpFrequency = this.D2CMethod{2};
        end
        zpkdata =  d2c(zpkdata,p);
    else
        if isequal(TsOrig,0)
            %c2d
            p = c2dOptions;
            if numel(this.C2DMethod)==1
                p.Method = this.C2DMethod{1};
            else
                p.Method = 'tustin';
                p.PrewarpFrequency = this.C2DMethod{2};
            end
            zpkdata =  c2d(zpkdata,Ts,p);
        else
            %d2d
            p = d2dOptions;
            if numel(this.C2DMethod)==1
                p.Method = this.C2DMethod{1};
            else
                p.Method = 'tustin';
                p.PrewarpFrequency = this.C2DMethod{2};
            end
            zpkdata =  d2d(zpkdata,Ts,p);
        end
    end
end