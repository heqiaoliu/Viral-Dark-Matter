function	num = find_formatter_type(str)
%FIND_CAPTION_TYPE Find the enumeration value from the enumeration string

%   Bill Aldrich
%   Copyright 1990-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/10 23:00:09 $

persistent Caption_Type_Strings Caption_Type_Values;

if isempty(Caption_Type_Strings)
	[prop,names]=cv('subproperty','formatter.keyNum');
	[Caption_Type_Strings,I]=sort(names{1});
	Caption_Type_Values = I-1;
end

% WISH with an ordered set of strings we could do something
% more sophisticated but for now just do a brute force search

testCell{1} = str;
Match = strcmp(testCell,Caption_Type_Strings);
Index = find(Match);
if isempty(Index),
    error('SLVNV:simcoverage:find_formatter_type:NoMatchFormatter','No formatters matches string');
end
if length(Index)>1,
    error('SLVNV:simcoverage:find_formatter_type:MultipleMatch','More than 1 formatter matches string');
end
num = Caption_Type_Values(Index);
