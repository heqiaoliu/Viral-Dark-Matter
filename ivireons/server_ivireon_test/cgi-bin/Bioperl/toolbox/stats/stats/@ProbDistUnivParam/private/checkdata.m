function [eid,emsg,x,cens,freq] = checkdata(spec,x,cens,freq)
%CHECKDATA Check data for fitting and return in consistent form
%    On return NaN and zero-frequency values will be squeezed out,
%    and if the distribution doesn't support censoring there will
%    be nothing in CENS or FREQ.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/22 04:42:02 $

eid = '';
emsg = '';

if ~isvector(x) || size(x,2)~=1
    eid = 'stats:ProbDistUnivParam:fit:BadData';
    emsg = 'X must be a column vector.';
    return
elseif isempty(x)
    eid = 'stats:ProbDistUnivParam:fit:BadData';
    emsg = 'X must not be empty.';
    return
elseif numel(x)<sum(~spec.prequired)
    eid = 'stats:ProbDistUnivParam:fit:BadData';
    emsg = 'Not enough data in X to fit this distribution.';
    return
end
n = numel(x);

% Check data, censoring, and frequency
bad = isnan(x);
if ~isempty(cens)
    if ~isvector(cens) || ~numel(cens)==n
        eid = 'stats:ProbDistUnivParam:fit:BadCensoring';
        emsg = 'CENSORING value must be empty or a vector of the same size as X.';
        return
    elseif any(cens) && ~spec.censoring
        eid = 'stats:ProbDistUnivParam:fit:BadCensoring';
        emsg = sprintf('Censoring not allowed with the %s distribution', spec.code);
        return
    elseif ~islogical(cens) && ~all(isnan(cens) | cens==0 | cens==1)
        eid = 'stats:ProbDistUnivParam:fit:BadCensoring';
        emsg = 'CENSORING value must be a logical vector.';
        return
    else
        bad = bad | isnan(cens);
    end
end
if ~isempty(freq)
    if ~isvector(freq) || ~numel(freq)==n
        eid = 'stats:ProbDistUnivParam:fit:BadFrequency';
        emsg = 'FREQUENCY value must be empty or a vector of the same size as X.';
        return
    elseif ~all(isnan(freq) | (freq>=0 & freq==round(freq)))
        eid = 'stats:ProbDistUnivParam:fit:BadFrequency';
        emsg = 'FREQUENCY values must be non-negative integers.';
        return
    else
        bad = bad | isnan(freq) | freq==0;
    end
end

% Remove bad values
x = x(~bad);
if ~isempty(cens)
    cens = cens(~bad);
end
if ~isempty(freq)
    freq = freq(~bad);
end
if ~spec.censoring && ~isempty(freq)
    x = expandInput(x,freq);
    freq = [];
end

% Check for inappropriate data
if ~spec.iscontinuous && any(x~=round(x))
    eid = 'stats:ProbDistUnivParam:fit:BadData';
    emsg = 'This distribution requires X values that are integers.';
    return
end

if spec.closedbound(1)
    ok = min(x)>=spec.support(1);
else
    ok = min(x)>spec.support(1);
end
if ok
    if spec.closedbound(2)
        ok = max(x)<=spec.support(2);
    else
        ok = max(x)<spec.support(2);
    end
end
if ~ok
    lsym = '([';
    lsym = lsym(spec.closedbound(1)+1);
    usym = ')]';
    usym = usym(spec.closedbound(2)+1);
    eid = 'stats:ProbDistUnivParam:fit:BadData';
    emsg = sprintf('All X values must be in the interval %s%d,%d%s.',...;
                   lsym,spec.support(1),spec.support(2),usym);
end

% -----------------------------
function expanded = expandInput(input,freq)
%EXPANDDATA Expand out an input vector using element frequencies.
i = cumsum(freq);
j = zeros(1, i(end));
j(i(1:end-1)+1) = 1;
j(1) = 1;
expanded = input(cumsum(j));
