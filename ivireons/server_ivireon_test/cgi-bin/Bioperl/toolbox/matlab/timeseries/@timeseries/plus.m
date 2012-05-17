function tsout = plus(ts1,ts2)

%PLUS  Overloaded element-by-element array addition
%
%    TS1+TS2: TS1 and TS2 must have the same length.  Their sample
%    sizes must be the same unless each sample in TS2 is a scalar.  
%    Note: the quality array of the output time series will be the
%    element-by-element minimum of the two quality arrays from TS1 and TS2.
%
%    TS1+B: the sample size of time series TS1 and the size of B must be
%    the same unless B is a scalar. 
%
%    A+TS1: the size of A and the sample size of time series TS1 must be
%    the same unless A is a scalar.  
%

%   Copyright 2005-2010 The MathWorks, Inc.

if isa(ts1,'timeseries')
    if numel(ts1)~=1
        error('timeseries:plus:noarray',...
         'The plus method can only be used for a single timeseries object');
    end
    if isa(ts2,'timeseries')
        if numel(ts2)~=1
           error('timeseries:plus:noarray',...
            'The plus method can only be used for a single timeseries object');
        end
        tsout = localplus(ts1,ts2);
    elseif isnumeric(ts2) || islogical(ts2)
        % Use option 'false' for ts\N
        tsout = localplus(ts1, ts2);
    else
        % Second input is not valid for operation
        error('timeseries:arith:typemix',...
            'Time series arithmetic operations cannot be performed on pair of timeseries object and %s object.',...
            class(ts2));
    end
else
    if isnumeric(ts1) || islogical(ts1)
        if numel(ts2)~=1
           error('timeseries:plus:noarray',...
            'The plus method can only be used for a single timeseries object');
        end
        % Use option 'true' for N\ts
        tsout = localplus(ts2,ts1);
    else
        error('timeseries:arith:typemix',...
            'Time series arithmetic operations cannot be performed on pair of %s object and timeseries object.',...
            class(ts1));
    end
end

function tsout = localplus(ts1, ts2)


if isa(ts2,'timeseries') 
    [commomTimeVector,outprops,warningFlag] = utArithCommonTime(ts1,ts2);
    % deal with empty object: return an empty ts which is consistent with
    % Matlab command 2+[], 2./[] etc.
    if isempty(commomTimeVector)
        tsout = timeseries;
        return
    end
    
    % If the IsTimeFirst properties of the two timeseries are different,
    % the output timeseries defaults to IsTimeFirst == true
    swarn = warning('off','timeseries:ctranspose:dep_ctrans');
    try
        if ts1.IsTimeFirst == ts2.IsTimeFirst
            tsout = ts1;
            if ts1.DataInfo.isstorage
                try
                    tsout.DataInfo = plus(ts1.DataInfo,ts2.DataInfo);
                catch %#ok<*CTCH>
                     [tsout.DataInfo,tsout.Data] = tsdata.datametadata.defaultplus(...
                        ts1.DataInfo,ts2.DataInfo,ts1.Data,ts2.Data);  
                end
            else
                [tsout.DataInfo,tsout.Data] = tsdata.datametadata.defaultplus(...
                    ts1.DataInfo,ts2.DataInfo,ts1.Data,ts2.Data);
            end
        elseif ~ts1.IsTimeFirst
            tsout = ts2;
            ts1_ = transpose(ts1);
            if ts1.DataInfo.isstorage
                try
                    tsout.DataInfo = plus(ts1_.DataInfo,ts2.DataInfo);
                catch
                    [tsout.DataInfo,tsout.Data] = tsdata.datametadata.defaultplus(...
                        ts1_.DataInfo,ts2.DataInfo,ts1_.Data,ts2.Data);
                end
            else
                [tsout.DataInfo,tsout.Data] = tsdata.datametadata.defaultplus(...
                    ts1_.DataInfo,ts2.DataInfo,ts1_.Data,ts2.Data);
            end
        elseif ~ts2.IsTimeFirst
            tsout = ts1;
            ts2_ = transpose(ts2);
            if ts1.DataInfo.isstorage
                try
                    tsout.DataInfo = plus(ts1.DataInfo,ts2_.DataInfo);
                catch
                    [tsout.DataInfo,tsout.Data] = tsdata.datametadata.defaultplus(...
                        ts1.DataInfo,ts2_.DataInfo,ts1.Data,ts2_.Data);
                end
            else
                [tsout.DataInfo,tsout.Data] = tsdata.datametadata.defaultplus(...
                    ts1.DataInfo,ts2_.DataInfo,ts1.Data,ts2_.Data);
            end
        end
    catch me
       warning(swarn)
       me.rethrow;
    end
    warning(swarn)
    tsout.Name = 'unnamed';
    
    tsout.Quality = [];
    tsout.Time = commomTimeVector;
    tsout.TimeInfo.StartDate = outprops.ref;
    tsout.TimeInfo.Units = outprops.outunits;
    tsout.TimeInfo.Format = outprops.outformat;
    tsout = timeseries.utarithcommonoutput(ts1,ts2,tsout,warningFlag);
else
    commomTimeVector = ts1.Time;
    
    % deal with empty object: return an empty ts which is consistent with
    % Matlab command 2+[], 2./[] etc.
    if isempty(commomTimeVector)
        tsout = timeseries;
        return
    end
    tsout = ts1;
    
    % Duplicate non-scalar numeric inputs over each sample (see command
    % line help for TS1+B or A+TS1)
    if ~isscalar(ts2)
        if ts1.isTimeFirst
            data = reshape(repmat(ts2,ts1.length,1),size(ts1.Data));
            if ts1.DataInfo.isstorage
                try
                    tsout.DataInfo = plus(ts1.DataInfo,data);  
                catch
                   [tsout.DataInfo,tsout.Data] = tsdata.datametadata.defaultplus(ts1.DataInfo,...
                       [],ts1.Data,data);
                end
            else
               [tsout.DataInfo,tsout.Data] = tsdata.datametadata.defaultplus(ts1.DataInfo,...
                   [],ts1.Data,data);
            end
        else
            data = reshape(repmat(ts2,1,ts1.length),size(ts1.Data));
            if ts1.DataInfo.isstorage
                try
                    tsout.DataInfo = plus(ts1.DataInfo,data);
                catch
                    [tsout.DataInfo,tsout.Data] = tsdata.datametadata.defaultplus(ts1.DataInfo,...
                       [],ts1.Data,data);    
                end
            else
                [tsout.DataInfo,tsout.Data] = tsdata.datametadata.defaultplus(ts1.DataInfo,...
                    [],ts1.Data,data);
            end
        end
    else
        if ts1.DataInfo.isstorage
            try
                tsout.DataInfo = plus(ts1.DataInfo,ts2);   
            catch
                [tsout.DataInfo,tsout.Data] = tsdata.datametadata.defaultplus(...
                 ts1.DataInfo,[],ts1.Data,ts2);
            end
        else
             [tsout.DataInfo,tsout.Data] = tsdata.datametadata.defaultplus(...
                 ts1.DataInfo,[],ts1.Data,ts2);
        end
    end
end
tsout.Time = commomTimeVector;


