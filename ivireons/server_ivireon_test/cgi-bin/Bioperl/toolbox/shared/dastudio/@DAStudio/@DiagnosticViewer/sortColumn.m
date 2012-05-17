function sortColumn(h, columnIndex)
%  SORTCOLUMN
%  sortColumn provides the functions for sorting
%  a column of the diagnostic viewer
%  Copyright 1990-2004 The MathWorks, Inc.

%  $Revision: 1.1.6.3 $


names1= {};
obj_names={};
obj_names_struct_number=struct([]);
obj_names_struct_str=struct([]);
sort_struct_number = struct([]);
sort_struct_str = struct([]);
counter1 = 0;
counter2 = 0;

%  Here walk through all messages and save the info
%  in an array

for i = 1:length(h.Messages)
    msg = h.Messages(i);
    name = find_string_to_sort(msg,columnIndex);
    obj_names= [obj_names name];
end

are_all_numbers=1; %checks whether all message are numbers
are_all_strings=1; %checks whether all message are strings
names1 = str2double(obj_names);
for i = 1:length(names1)
    if isnan(names1(i))
        are_all_numbers=0;
    else
        are_all_strings=0;
    end
end


% sort these indices
if are_all_numbers
    [b indx] = sort(lower(names1));
elseif are_all_strings
    [b indx] = sort(lower(obj_names));
else
    % For combination of strings and numbers
    for i=1:length(obj_names)
        name1 = str2double(obj_names(i));
        if isnan(name1)
            counter1 = counter1+1;
            obj_names_struct_str(counter1).name = obj_names(i); %Stores all the string types into obj_names_struct_str structure
            obj_names_struct_str(counter1).index =i;
        else
            counter2 = counter2 + 1;
            obj_names_struct_number(counter2).name = name1; %Stores all the number types into obj_names_struct_number structure
            obj_names_struct_number(counter2).index =i;
        end
    end

    for i = 1:length(obj_names_struct_number)
        unsorted_numbers(i) = obj_names_struct_number(i).name; %Take the numbers into unsorted_numbers, later they are sorted in sorted_numbers
    end
    sorted_numbers = sort(unsorted_numbers);
    counter = 0;
    for i = 1:length(sorted_numbers)
        for j = 1:length(obj_names_struct_number)
            if obj_names_struct_number(j).name == sorted_numbers(i)
                counter = counter+1;
                sort_struct_number(counter).name = num2str(sorted_numbers(i));
                sort_struct_number(counter).index = obj_names_struct_number(j).index;
                obj_names_struct_number(j).name = '';
                break;
            end
        end
    end

    for i = 1:length(obj_names_struct_str)
        unsorted_strings(i) = obj_names_struct_str(i).name; %Take the numbers into unsorted_strings, later they are sorted in sorted_strings
    end
    sorted_strings = sort(unsorted_strings);
    counter = 0;
    for i = 1:length(sorted_strings)
        for j = 1:length(obj_names_struct_str)
            if strcmp(sorted_strings(i), obj_names_struct_str(j).name)
                counter = counter+1;
                sort_struct_str(counter).name = sorted_strings(i);
                sort_struct_str(counter).index = obj_names_struct_str(j).index;
                obj_names_struct_str(j).name = '';
                break;
            end
        end
    end

    final_array_size = length(sort_struct_number) + length(sort_struct_str);
    b=cell(1, final_array_size);
    indx=zeros(1, final_array_size);

    for i = 1:length(sort_struct_number)
        b(i) = {sort_struct_number(i).name};
        indx(i) = sort_struct_number(i).index;
    end

    for j = 1:length(sort_struct_str)
        b(i+j) = {sort_struct_str(j).name};
        indx(i+j) = sort_struct_str(j).index;
    end
end


% You may have to reverse your order of sorting
% if the user clicks on the header twice
tmp = h.reverseSort;
if (h.reverseSort(columnIndex) > 0)
    indx = fliplr(indx);
    tmp(columnIndex) = -1.0;
else
    tmp(columnIndex) = 1.0;
end
% Here make sure you set the reverseSort to be tmp
h.reverseSort = tmp;
% Here remember which row is selected you have to
% set the same row as being selected afterwards
row = h.rowSelected;
newIndex = find(indx==row);
% Here you rearrange the h.Messages
h.Messages = h.Messages(indx);
% Let java reflect what is in m
% Here set the selected row to be the same
% as it was before you rearranged your rows
h.synchronizeJavaViewer(newIndex);

% this is a helper function meant to find the appropriate string
% based on the column involved
function str2 = find_string_to_sort(msg,columnIndex)

c = msg.Contents;

switch(columnIndex)
    case 1,
        str2 = cellstr(msg.Type);
    case 2,
        str2 = cellstr([c.Type ,'/', msg.Type]);
    case 3, str2 = cellstr(msg.sourceName);
    case 4, str2 = cellstr(msg.Component);
    case 5, str2 = cellstr(c.Summary);
end