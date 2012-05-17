function printofficeassign(x)
%PRINTOFFICEASSIGN creates a figure with the result of the assignment problem.
% This is a helper function for the demo officeassign.

%   Copyright 1990-2006 The MathWorks, Inc.
%   $Revision.4 $  $Date: 2007/08/03 21:32:03 $

numPeople = 7;
for i=1:numPeople
    office{i} = find(x(i:numPeople:end));
end

people = {'Mary Ann', 'Marjorie','  Tom   ',' Peter  ','Marcelo ',' Rakesh '};
for i=1:numPeople
    if isempty(office{i})
        name{i} = ' empty  ';
    else
        name{i} = people(office{i});
    end
end
figure
axis off
set(gcf,'color','w');
text(0.1, .73, name{1});
text(.35, .73, name{2});
text(.60, .73, name{3});
text(.82, .73, name{4});

text(.35, .42, name{5});
text(.60, .42, name{6});
text(.82, .42, name{7});


