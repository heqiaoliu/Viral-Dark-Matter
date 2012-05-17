function str = qpointstr(this)
%QPOINTSTR Q-point string
%   QPOINTSTR(A) returns the qpoint string that is used in numerictype
%   display 'short'.

%   Copyright 2003-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2006/12/20 07:12:43 $

str = '';

if isscaledtype(this)
    if issigned(this) 
        str = [str 's']; 
    else 
        str = [str 'u']; 
    end
    if isscaleddouble(this) 
        str = [str 'flt'];
    end
    switch lower(this.scaling);
        case 'binarypoint'
            str = [str,num2str(this.wordlength),',',num2str(this.fractionlength)];
        case 'slopebias'
            if isfixed(this) 
                str = [str 'fix'];
            end
            str = [str,num2str(this.wordlength)];
            if this.SlopeAdjustmentFactor==1 && this.Bias==0
                str = [str,'_En',num2str(this.fractionlength)];
            else
                slopestr = num2str(this.Slope,'%0.16g');
                k=findstr(slopestr,'.');slopestr(k)='p';
                bias = num2str(this.bias,'%0.16g');
                k=findstr(bias,'.');bias(k)='p';
                str = [str,'_S',slopestr,'_B',bias];
            end
        otherwise
            str = [str, num2str(this.wordlength)];
    end    
else
    str = this.datatype;
end

