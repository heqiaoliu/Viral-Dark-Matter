function deleterows(h,thisSelectedRows, varargin)

% DELETEROWS   Deletes selected rows from the table. If the third argument
% is the string 'withoutshuffle' then the rows are deleted without
% shuffling the remaining rows

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2005/12/22 17:38:55 $

thisSignals = h.inputsignals;
emptyRow = struct('values',{[]},'source',{''},'subsource',{''},'construction',{''},...
'interval',{[]},'column',{[]},'name',{''},'transposed',false,'size',[0 0]);
if nargin<=2 || (nargin>2 && strcmp(varargin{1},'withshuffle'))
	thisSignals(thisSelectedRows) = [];
	thisSignals = [thisSignals repmat(emptyRow,1,length(thisSelectedRows))];
else
    thisSignals(thisSelectedRows) = repmat(emptyRow,1,length(thisSelectedRows));
end
h.inputsignals = thisSignals;
h.update;

