function [err,d,c,f,wmsg]=dfcheckselections(data,censoring,frequency,dval,cval,fval)

% For use by DFITTOOL

%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:28:38 $
%   Copyright 2003-2008 The MathWorks, Inc.

err = '';
wmsg = '';
d_l = 0;
c_l = 0;
f_l = 0;
NONE = '(none)';
d = [];
c = [];
f = [];

dblwarn = false;  % warn about conversion to double

% If there's no data vector input, and not even a name or expression, then
% there's really no data, and it's an error.
if (nargin<4) && (isempty(data) || isequal(data, NONE) || all(isspace(data(:))))
    if isequal(data, NONE)
        err = sprintf('Invalid Data Choice: %s.\n', NONE);
    else
        err = sprintf('Data must be specified.\n');
    end
    
% Otherwise, there may be a data vector and no name/expression, and we give it
% a default name; or there may be a name/expression and no vector, and we will
% eval to get the data.
else
    if isempty(data)
        dataname = 'Data variable';
    else
        dataname = sprintf('Data variable "%s"',data);
    end
    try
        if nargin<4
            dval = evalin('base',data);
        end
        if ~isa(dval,'double')
            d = double(dval);
            dblwarn = true;
        else
            d = dval;
        end
        if isvector(d) && (length(d) > 1)
            if any(isinf(d))
               err = sprintf('%s cannot contain Inf or -Inf.\n', dataname);
            elseif ~isreal(d)
               err = sprintf('%s cannot be complex.\n', dataname);
            elseif sum(~isnan(d))==0
               err = sprintf('%s contains all NaN values.\n', dataname);
            else
               d_l = length(d);
            end
        else
            if ~isvector(d)
               err = sprintf('%s is not a vector.\n', dataname);
            else
               err = sprintf('%s does not contain at least 2 observations.\n', dataname);
            end
        end
    catch ME
        err = [err sprintf('Invalid expression: %s\n %s.\n', dataname, ME.message)];
    end
end

% If there's no censoring vector input, and not even a name or expression,
% then there's really no censoring.
if (nargin<5) && (isempty(censoring) || isequal(censoring, NONE) || all(isspace(censoring(:))))
    c_l = -1;
    
% Otherwise, there may be a censoring vector and no name/expression, and we
% give it a default name; or there may be a name/expression and no vector, and
% we will eval to get the vector.
else
    if isempty(censoring)
        censname = 'Censoring variable';
    else
        censname = sprintf('Censoring variable "%s"',censoring);
    end
    try
        if nargin<5
            cval = evalin('base',censoring);
        end
        if ~isa(cval,'double')
            if ~isa(cval,'logical')
               dblwarn = true;
            end
            c = double(cval);
        else
            c = cval;
        end
        if isempty(c)
           c_l = -1;
        elseif isvector(c) && (length(c) > 1)
            if ~all(ismember(c, 0:1))
                err = [err sprintf('%s must be a logical vector.\n',censname)];
            elseif any(isinf(c))
                err = [err sprintf('%s cannot contain Inf or -Inf.\n', censname)];
            elseif ~isreal(c)
                err = [err sprintf('%s cannot be complex.\n', censname)];
            else
                c_l = length(c);
            end
        else
            err = [err sprintf('%s is not a vector.\n', censname)];
        end
    catch ME
        err = [err sprintf('Invalid expression: %s\n %s\.n', censname, ME.message)];
    end
end

% If there's no frequency vector input, and not even a name or expression,
% then there's really no frequencies.
if (nargin<6) && (isempty(frequency) || isequal(frequency, NONE) || all(isspace(frequency(:))))
    f_l = -1;

% Otherwise, there may be a frequency vector and no name/expression, and we
% give it a default name; or there may be a name/expression and no vector, and
% we will eval to get the vector.
else
    if isempty(frequency)
        freqname = 'Frequency variable';
    else
        freqname = sprintf('Frequency variable "%s"',frequency);
    end
    try
        if nargin<6
            fval = evalin('base',frequency);
        end
        if ~isa(fval,'double')
            if ~isa(fval,'logical')
               dblwarn = true;
            end
            f = double(fval);
        else
            f = fval;
        end
        if isempty(f)
           f_l = -1;
        elseif isvector(f) && (length(f) > 1)
            if any(f<0) || any(f~=round(f) & ~isnan(f))
               err = [err sprintf('%s values must be non-negative integers.\n',freqname)];
            elseif any(isinf(f))
               err = [err sprintf('%s cannot contain Inf or -Inf.\n', freqname)];
            elseif ~isreal(f)
               err = [err sprintf('%s cannot be complex.\n', freqname)];
            else
               f_l = length(f);
            end
        else
            err = [err sprintf('%s is not a vector.\n', freqname)];
        end
    catch ME
        err = [err sprintf('Invalid expression: %s\n %s.\n', freqname, ME.message)];
    end
end

% Check lengths if no other errors
if isequal(err, '')
    if ((c_l ~= -1) && (c_l ~= d_l)) || ((f_l ~= -1) && (f_l ~= d_l))
        err = sprintf('Vector lengths must be equal.\n');
        err = [err sprintf('    Data length: %d.\n', d_l)];
        if (c_l ~= -1) && (c_l ~= d_l)
            err = [err sprintf('    Censoring length: %d.\n', c_l)];
        end
        if (f_l ~= -1) && (f_l ~= d_l)
            err = [err sprintf('    Frequency length: %d.\n', f_l)];
        end
    end
end

% Must have some non-censored data
if isempty(err) && c_l~=-1
   if (f_l==-1 && all(c==1)) || (f_l~=-1 && all(c(f>0)==1))
      err = 'Cannot have all observations censored.';
   end
end

% Warn if we had to convert to double
if isempty(err) && dblwarn
   wmsg = sprintf('Distribution Fitting Tool requires double inputs.\nNon-double inputs have been converted to double.');
end
      
