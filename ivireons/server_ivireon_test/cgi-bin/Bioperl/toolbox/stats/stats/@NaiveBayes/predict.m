function gpre = predict(obj,test,varargin)
%PREDICT Predict class label for test data.
%   CPRE = PREDICT(NB,TEST) classifies each row in TEST into one of
%   the classes according to the NaiveBayes classifier NB, and returns the
%   predicted class level CPRE. TEST is an N-by-NB.NDIMS matrix, where N
%   is the number of observations in the test data. Rows of TEST correspond
%   to points, columns of TEST correspond to features. CPRE is an N-by-1
%   vector of the same type as NB.CLASSLEVELS, and it indicates the class
%   to which each row of TEST has been assigned.
%
%   CPRE = PREDICT(..., 'HandleMissing',VAL) specifies how NaN (missing
%   values) in TEST are treated. VAL can be one of the following:
%       'off' (default) Observations with NaN in any of columns are not
%             classified into any class. The corresponding rows in CPRE are
%             NaN (if OBJ.CLASSLEVELS is numeric or logical), empty strings
%             (if OBJ.CLASSLEVELS is char or cell array of strings) or
%             <undefined> (if OBJ.CLASSLEVELS is categorical).
%       'on'  For observations having NaN values in some (but not all) of
%             columns CPRE is computed using the columns with non-NaN
%             values. 
%
%   See also NAIVEBAYES, FIT, POSTERIOR.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/16 00:18:53 $

if nargin < 2
    error('stats:NaiveBayes:predict:TooFewInputs',...
        'At least two input arguments required.');
end

if ~isnumeric(test) 
    error('stats:NaiveBayes:predict:TestBadType',...
        'TEST must be numeric.');
end

 if size(test,2)~= obj.NDims
      error('stats:NaiveBayes:BadTestSize',...
             'The number of columns of TEST must be equal to %d.',obj.NDims);
 end
 
pnames = {'handlemissing'};
dflts = {'off'};
[eid,errmsg,handleMissing] ...
    = internal.stats.getargs(pnames, dflts, varargin{:});
if ~isempty(eid)
    error(sprintf('stats:NaiveBayes:predict:%s',eid),errmsg);
end
handleMissing = dfswitchyard('statgetkeyword',...
    handleMissing,{'on' 'off'},false,'HandleMissing', ...
    'stats:NaiveBayes:predict:BadHandleMissing');

if strcmp(handleMissing,'off')
    wasInvalid =  any(isnan(test),2);
else
    wasInvalid = all(isnan(test),2);
end

if isscalar(obj.Dist) && strcmp(obj.Dist,'mn')
    testBad = any(test<0 |test ~= round(test),2);
    if any(testBad)
        warning('stats:NaiveBayes:predict:BadDataforMN',...
       [ 'TEST must be a matrix of non-negative integers for ''mn'' distribution. ',...
       'Rows of TEST with invalid values will be ignored.']);
         wasInvalid = wasInvalid | testBad;
    end
end

hadInvalid = any(wasInvalid);
if hadInvalid
    test(wasInvalid,:)= [];
end

log_condPdf = getlogCondPDF(obj,test,handleMissing);
gpre = getClassIdx(obj,log_condPdf);
%convert class index to the corresponding class levels

isGpreNaN= isnan(gpre);
gpre= obj.ClassLevels(gpre(~isGpreNaN),:);
if any(isGpreNaN)
    gpre= dfswitchyard('statinsertnan',isGpreNaN,gpre);
end

if hadInvalid
    gpre = dfswitchyard('statinsertnan', wasInvalid, gpre);
end

end
