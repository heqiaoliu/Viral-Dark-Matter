function out = fnd_runsearch(in1,in2)
%OUT = FND_RUNSEARCH( IN1, IN2 )  Performs the search

%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.15.2.4 $  $Date: 2009/01/29 17:29:29 $

   out = i_perform_search(in1,in2);

function resultHandles = i_perform_search(searchCriteria,searchSpace)

% Property cell arrays (for finding strings)

sfNames = {'state.name','data.name','event.name','chart.name','target.name'};
sfLabels = {'state.labelString','transition.labelString',...
             'junction.labelString'};


%
% First narrow the search space by object type
%

objectTypeNames = {'state.id', ...
                'transition.id', ...
                'junction.id', ...
                'event.id', ...
                'data.id', ...
                'target.id'};

spaceMat = sf('get',searchSpace, ...
   objectTypeNames{find(searchCriteria.type(1:6))});

% Roll up the results:
dims = spaceMat;
spaceVect = spaceMat(1:numel(dims));
searchSpace = spaceVect(find(spaceVect));	% Get rid of zero elements

%
% filter out subTransitions jt
%
subTrans = sf('find', searchSpace, 'transition.type', 'SUB');
searchSpace = vset(searchSpace, '-', subTrans);

% filter out SL in SF functions and their children
slFcns = sf('find', searchSpace, 'state.simulink.isSimulink', 1);
searchSpace = vset(searchSpace, '-', slFcns);
% Filter out data objects belonging to SL functions.
searchData = sf('get', searchSpace, 'data.id');
for i=1:length(searchData)
    d = searchData(i);
    p = sf('get', d, '.linkNode.parent');
    if isequal(sf('get', p, 'state.simulink.isSimulinkFcn'), 1)
        searchSpace = vset(searchSpace, '-', d);
    end
end

% Now the search should be narrowed by string

if ~isempty(searchCriteria.string)

  switch searchCriteria.searchMethod
    case 2,
      regexpString = char(['\<' searchCriteria.string '\>']);	 
    otherwise,
      regexpString = searchCriteria.string;
  end

  switch searchCriteria.stringLocation
  
    case 2,  % Search the labels
	  numSearchPairs = length(sfLabels);
	  searchPairs(1:2:(2*numSearchPairs-1)) = sfLabels;
	  searchPairs(2:2:(2*numSearchPairs)) = {regexpString};
	  searchSpace = sf('regexp', searchSpace, searchPairs{:}, searchCriteria.caseInsensitive);

    case 3,  % Search the names
	  numSearchPairs = length(sfNames);
	  searchPairs(1:2:(2*numSearchPairs-1)) = sfNames;
	  searchPairs(2:2:(2*numSearchPairs)) = {regexpString};
	  searchSpace = sf('regexp', searchSpace, searchPairs{:}, searchCriteria.caseInsensitive);

    case 4,  % Search the descriptions
 	  searchSpace = sf('regexp', searchSpace, '.description', regexpString, searchCriteria.caseInsensitive);

    case 5,  % Search the Document Links
 	  searchSpace = sf('regexp', searchSpace, '.document', regexpString, searchCriteria.caseInsensitive);

    case 6,  % Search the Custom Code
 	  searchSpace = sf('regexp', searchSpace, 'target.customCode', regexpString, searchCriteria.caseInsensitive);

    otherwise,  % Search everywhere
	  % Find label matches
	  numSearchPairs = length(sfLabels);
	  searchPairs(1:2:(2*numSearchPairs-1)) = sfLabels;
	  searchPairs(2:2:(2*numSearchPairs)) = {regexpString};
	  searchSpace1 = sf('regexp', searchSpace, searchPairs{:}, searchCriteria.caseInsensitive);

	  % Find the name matches
	  numSearchPairs = length(sfNames);
	  searchPairs(1:2:(2*numSearchPairs-1)) = sfNames;
	  searchPairs(2:2:(2*numSearchPairs)) = {regexpString};
	  searchSpace2 = sf('regexp', searchSpace, searchPairs{:}, searchCriteria.caseInsensitive);

	  % Find description matches
 	  searchSpace3 = sf('regexp', searchSpace, '.description', regexpString, searchCriteria.caseInsensitive);
 	  
	  % Find Document Link Matches
	  searchSpace4 = sf('regexp', searchSpace, '.document', regexpString, searchCriteria.caseInsensitive);

	  % Find Custom Code Matches
 	  searchSpace5 = sf('regexp', searchSpace, 'target.customCode', regexpString, searchCriteria.caseInsensitive);

 	  % Find the union of all searches
	  searchSpace = vset([searchSpace1 searchSpace2 searchSpace3 searchSpace4 searchSpace5]);

  end
  
end

%
% First narrow the search space by object type
%

objectTypeNames = {'state.id', ...
                'transition.id', ...
                'junction.id', ...
                'event.id', ...
                'data.id', ...
                'target.id'};

spaceMat = sf('get',searchSpace, ...
   objectTypeNames{find(searchCriteria.type(1:6))});

% Roll up the results:
dims = spaceMat;
spaceVect = spaceMat(1:numel(dims));
searchSpace = spaceVect(find(spaceVect));	% Get rid of zero elements

resultHandles = searchSpace; 

