function [tf,duplicated] = checkduplicatenames(names1,names2,okLocs)
%CHECKDUPLICATENAMES Check for duplicated dataset array variable or observation names.

%   Copyright 2006-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2009/05/07 18:27:30 $

% Check for any duplicate names in names1
if nargin == 1
    % names1 is always a cellstr
    duplicated = false(size(names1));
    names1 = sort(names1);
    duplicated(2:end) = strcmp(names1(1:end-1),names1(2:end));
    
% Check if any name in names1 is already in names2.  This does not check if
% names1 contains duplicates within itself
elseif nargin == 2
    % names2 is always a cellstr
    if ischar(names1) % names1 is either a single string ...
        duplicated = any(strcmp(names1, names2));
    else             % ... or a cell array of strings
        duplicated = false(size(names1));
        for i = 1:length(names1)
            duplicated(i) = any(strcmp(names1{i}, names2));
        end
    end

% Check if any name in names1 is already in names2, except that names1(i) may
% be at names2(okLocs(i)).  This does not check if names1 contains duplicates
% within itself
else
    % names2 is always a cellstr
    if ischar(names1) % names1 is either a single string ...
        tmp = strcmp(names1, names2); tmp(okLocs) = false;
        duplicated = any(tmp);
    else             % ... or a cell array of strings
        duplicated = false(size(names1));
        for i = 1:length(names1)
            tmp = strcmp(names1{i}, names2); tmp(okLocs(i)) = false;
            duplicated(i) = any(tmp);
        end
    end
end

tf = any(duplicated);

if (nargout == 0) && tf
    error('stats:dataset:checkduplicatenames:DuplicateNames','Duplicate names.');
end
