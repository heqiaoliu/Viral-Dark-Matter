function [spec, errMsg] = checkSldvSpecification(spec)
% Validate and normalize an Sldv specification

%   Copyright 2007-2008 The MathWorks, Inc.

% A specification is a cell array, or a single element of
% points, intervals, and [], given using either the 
% Sldv.Point and Sldv.Interval class, or the short notation
% supported by sldv in the scalar case.
%
% The result is a cell array using only the class. 
    errMsg = '';

    try
    if iscell(spec)
        for i=1:length(spec)
            spec{i} = checkElem(spec{i});
        end
    else
        spec = { checkElem(spec) };
    end
    catch myException %#ok<NASGU>
        spec = {};
        errMsg = 'Syntax error in the parameter ''Values'' of the %s block.';
    end
end
    
function elem = checkElem(spec)   
    if isa(spec,'Sldv.Point') || isa(spec,'Sldv.Interval')
        elem = spec;
        
    elseif isnumeric(spec) || islogical(spec)
        if isempty(spec)
            elem = [];
        elseif length(spec) == 1
            elem = Sldv.Point(spec);
        elseif (length(spec) == 2)
            elem = Sldv.Interval(spec(1), spec(2));
        else
            error('SLDV:CheckSpec:Syntax', 'Syntax error');
        end

    else
        error('SLDV:CheckSpec:Syntax', 'Syntax error');
    end
end 
