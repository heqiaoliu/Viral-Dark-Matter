function errmsg = validate_power_output_type(a, k, ismpower)
%VALIDATE_POWER_OUTPUT_TYPE Internal use only: compute and check output type

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/10/24 19:04:14 $

awl = a.wordlength;
isipreal = isreal(a);
fm = fimath(a);
pmode = fm.productmode;
smode = fm.summode;
isprodwlconst = strcmpi(pmode,'KeepMSB')||strcmpi(pmode,'KeepLSB')||strcmpi(pmode,'SpecifyPrecision');
issumwlconst = strcmpi(smode,'KeepMSB')||strcmpi(smode,'KeepLSB')||strcmpi(smode,'SpecifyPrecision');

maxpwlen = fm.MaxProductWordLength;
maxswlen = fm.MaxSumWordLength;

errmsg = '';
prodwlenexceeded = false;
sumwlenexceeded = false;

if ~ismpower
    % Element-by-element Power
    if ~isprodwlconst && ~issumwlconst
        
        % both product and sum modes are full precision
        if isipreal
            
            prodwlen = k*awl;
        else
            
            prodwlen = k*awl + (k-2);
            sumwlen = k*awl + (k-1);
            sumwlenexceeded = (sumwlen > maxswlen);
        end
        prodwlenexceeded = (prodwlen > maxpwlen);
        
    elseif ~isprodwlconst
        
        % prod mode is full precision; sum mode is not
        if isipreal
            
            prodwlen = k*awl;
        else
            
            prodwlen = (a.sumwordlength+awl);
        end
        prodwlenexceeded = (prodwlen > maxpwlen);
        
    elseif ~issumwlconst
        
        % sum mode is full precision, product mode is not
        if ~isipreal
            
            sumwlen = (a.productwordlength+1);
            sumwlenexceeded = (sumwlen > maxswlen);
        end
    end
else
    % Matrix Power
    n = size(a,1);
    nb = ceil(log2(n));
    if ~isipreal
        nbcplx = ceil(log2(n+1));
    end
    % Matrix-power algorithm
    if ~isprodwlconst && ~issumwlconst
        
        % both product and sum modes are full precision
        if isipreal
            
            prodwlen = k*awl + (k-2)*nb;
            sumwlen = k*awl + (k-1)*nb;
        else
            
            prodwlen = k*awl + (k-2)*nbcplx;
            sumwlen = k*awl + (k-1)*nbcplx;
        end
        prodwlenexceeded = (prodwlen > maxpwlen);
        sumwlenexceeded = (sumwlen > maxswlen);
    elseif ~issumwlconst
        
        if isipreal
            
            sumwlen = a.productwordlength + nb;
        else
            
            sumwlen = a.productwordlength + nbcplx;
        end
        sumwlenexceeded = (sumwlen > maxswlen);
    elseif ~isprodwlconst
        if (k > 2)
            if isipreal 

                pwlen = a.sumwordlength + a.wordlength;
            else

                pwlen = a.sumwordlength + a.wordlength + 1;
            end
            prodwlenexceeded = (pwlen > maxpwlen);            
        end
    end
end
if prodwlenexceeded

    errmsg = sprintf(['The computed product word length of the result is %d bits. ' ...
        'This exceeds MaxProductWordLength setting of %d bits.'], prodwlen, maxpwlen);
elseif sumwlenexceeded

    errmsg = sprintf(['The computed sum word length of the result is %d bits. ' ...
        'This exceeds MaxSumWordLength setting of %d bits.'], sumwlen, maxswlen);
end    
