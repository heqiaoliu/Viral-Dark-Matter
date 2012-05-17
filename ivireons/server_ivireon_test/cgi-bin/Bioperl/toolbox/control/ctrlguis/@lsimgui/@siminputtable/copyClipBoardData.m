function  copyClipBoardData(h,selectedRows)      

% COPYCLIPBOARDDATE copies the reference for the currently selected
% data to the lsimgui clipboard

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2005/12/22 17:38:54 $
values = {h.inputsignal(selectedRows).values};
% Only create a clipboard entry if copied data is non-empty otherwise
% menus will indicate a paste is possible when the clipbaord is vacouous
if ~all(cellfun('isempty',values)) 
    copyStruc = struct('source',{'inp'},'subsource',{{h.inputsignal(selectedRows).subsource}},...
       'data', {values},'construction',{{h.inputsignal(selectedRows).construction}},...
       'columns',{{h.inputsignal(selectedRows).column}}, ...
       'transposed',[h.inputsignal(selectedRows).transposed]);

    % Additional two items for internal table copy
    copyStruc.intervals = [h.inputsignal(selectedRows).interval];
    copyStruc.tablesources = {h.inputsignal(selectedRows).source};
    copyStruc.names = {h.inputsignal(selectedRows).name};
    copyStruc.size = [h.inputsignal(selectedRows).size];

    h.copieddatabuffer = copyStruc;

    % Enable the paste and insert menus
    h.STable.getModel.setMenuStatus([1 1 1 1 1]);
end