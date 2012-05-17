function updateParams(this)
% UPDATEPARAMS Calculates the parameters from the zpk representation

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.9 $  $Date: 2009/11/09 16:22:21 $

if ~isempty(this.ZPK2ParFcn)
    % Only update when there are parameters to update
    if isTunable(this)

        [Z,P] = getPZ(this);
        K = this.getZPKGain;
        
        zpkdata = ltipack.zpkdata({Z},{P},K,this.Ts);
        zpkdata = localConvertTs(this,zpkdata);

        if iscell(this.ZPK2ParFcn)
            NewParams = feval(this.ZPK2ParFcn{1},this.Parameters,[zpkdata.z{:}],...
                [zpkdata.p{:}],zpkdata.k,this.ZPK2ParFcn{2:end});
        else
            NewParams = this.ZPK2ParFcn(this.Parameters,[zpkdata.z{:}], ...
                [zpkdata.p{:}],zpkdata.k);
        end

        this.Parameters = NewParams;
    else
        % if not tunable parameters should not be updateable
    end
end


function zpkdata = localConvertTs(this,zpkdata)

Ts = this.Ts;
TsOrig = this.TsOrig;

if ~isequal(Ts,TsOrig)
    if isequal(TsOrig,0)
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
        if isequal(Ts,0)
            %c2d
            p = c2dOptions;
            if numel(this.C2DMethod)==1
                p.Method = this.C2DMethod{1};
            else
                p.Method = 'tustin';
                p.PrewarpFrequency = this.C2DMethod{2};
            end
            zpkdata =  c2d(zpkdata,TsOrig,p);
        else
            %d2d
            p = d2dOptions;
            if numel(this.C2DMethod)==1
                p.Method = this.C2DMethod{1};
            else
                p.Method = 'tustin';
                p.PrewarpFrequency = this.C2DMethod{2};
            end
            zpkdata =  d2d(zpkdata,TsOrig,p);
        end
    end
end
