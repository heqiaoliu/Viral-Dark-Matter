function [result,ind] = xeval(expr,tslist)
%XEVAL Time series expression evaluation
%
%   Author(s): James G. Owen
%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $ $Date: 2008/08/20 22:59:18 $

% Evaluate an expression using ordinate data from a cell array of time
% series passed as the second argument. The names of vectors in the 
% expression match the names of the time series in tslist.

%% Sort the time series by length of name. This will allow the expression
%% parser to detect occurrences of the longest time series name first so
%% that subsumed time series names are not articically detected
tsnames = cell(length(tslist),1);
for k=1:length(tslist)
    tsnames{k} = tslist{k}.Name;
end
[junk,J] = sort(-cellfun('length',tsnames));
tsnames = tsnames(J);
tslist = tslist(J);

% Create local variables with names defined by the time series object
% names and values defined by the @timeseries ordinate data
ind = [];
tmpexpr = expr;
for k=1:length(tsnames)
    pos = strfind(tmpexpr,tsnames{k});
    if ~isempty(pos) && sum(strcmp(tsnames{k},tsnames))>=2
        error('timeseries:xeval','Duplicate time series names');
    elseif ~isempty(pos)
       % Create a local variable containig
       data = tslist{k}.Data;
       eval(sprintf('%s = data;',tslist{k}.Name));
       ind = [ind;k];
       
       % Remove occurrences of this time series name from the expression
       % so that time series who's names are subsumed by longer time series
       % names are not falsly detected within longer time series names
       I = [];
       for j=1:length(pos)
           I = [I, pos(j):pos(j)+length(tsnames{k})-1];
       end
       tmpexpr(I) = '';
    end
end

% Evaluate expression using time series data
result = eval(sprintf('%s;',expr));
ind = J(ind);


