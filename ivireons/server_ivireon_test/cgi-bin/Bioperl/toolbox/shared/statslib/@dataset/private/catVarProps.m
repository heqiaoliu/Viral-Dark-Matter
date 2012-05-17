function prop = catVarProps(aprop,bprop,avars,bvars)
%CATVARPROPS Concatenate per-variable cellstr properties
%   P = CATVARPROPS(APROP,BPROP,AVARS,BVARS,NVARS) returns a cellstr
%   containing [APROP(AVARS) BPROP(BVARS)], accounting for the possibility
%   that one or both of APROP or BPROP are empty

%   Copyright 2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2009/04/15 23:35:22 $

if ~isempty(aprop) || ~isempty(bprop)
    nvars = length(avars) + length(bvars);
    prop = repmat({''},1,nvars);
    if ~isempty(aprop)
        prop(1:length(avars)) = aprop(avars);
    end
    if ~isempty(bprop)
        prop((length(avars)+1):nvars) = bprop(bvars);
    end
else
    prop = {};
end
