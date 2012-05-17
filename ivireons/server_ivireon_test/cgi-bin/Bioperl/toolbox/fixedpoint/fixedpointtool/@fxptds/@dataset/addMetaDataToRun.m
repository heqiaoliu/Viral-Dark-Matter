function addMetaDataToRun(h, runID)
%ADDMETADATATORUN % Add the Signals4Blk, list4id & blklist4src maps to the run. 

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/04/05 22:16:19 $


% Initialize the DataMap to contain a character key and a UDD object as value.
listmap = Simulink.sdi.Map(char('a'),?handle);
% Initialize the DataMap to contain a character key and a UDD object as value.
listmap.insert('list4id',Simulink.sdi.Map(char('a'),?handle));
% Initialize the LinkedHashMap to contain the block object as key and a
% pathItemID Java LinkedHashMap as value
listmap.insert('Signals4Blk',java.util.LinkedHashMap); 
% Initialize a Java LinkedHashMap to contain the block object as key and a
% UDD object as value. Cannot use SDI Maps since we need to store unique
% block identifiers. Block Handle is not an option since stateflow objects
% do not have this property.
listmap.insert('blklist4src',java.util.LinkedHashMap);

% insert the map into the RunData map.
h.RunDataMap.insert(runID, listmap);

%---------------------------------------------------------
% [EOF]
