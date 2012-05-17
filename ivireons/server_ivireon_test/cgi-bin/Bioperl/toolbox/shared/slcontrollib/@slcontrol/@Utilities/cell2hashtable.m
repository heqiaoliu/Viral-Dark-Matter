function hashtable = cell2hashtable(this,keystrcell)
% CELL2HASHTABLE  Convert a set of keys and strings to a java hash table.
%
% EX:
%   keystrcell = {'DialogTitle',xlate('Operating Point Selection');...
%                 'InstructLabel' xlate('Select a single operating point:');...
%                 'OK', xlate('OK');...
%                 'Cancel', xlate('Cancel')};
%   strhash = cell2hashtable(slcontrol.Utilities,keystrcell);

% Author(s): John W. Glass 06-Sep-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 14:00:55 $

hashtable = java.util.Hashtable;

%% Populate the hash table
for ct = 1:size(keystrcell,1)
    hashtable.put(keystrcell{ct,1},keystrcell{ct,2});
end