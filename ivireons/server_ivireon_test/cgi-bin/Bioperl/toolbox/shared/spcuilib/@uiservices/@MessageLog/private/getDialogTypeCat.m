function [mType,mCat] = getDialogTypeCat(this)
%getDialogTypeCat Return type and category selected in dialog.
%   Note: could be 'All' for each popup.

% Copyright 2004-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2010/01/25 22:48:07 $

% enumeration index is 0-based, and matches
% the list cached in UserData

TypeList = {'All','Info','Warn','Fail'};
CatList = [{'All'}, catList(this)];

mType = TypeList{this.SelectedType+1};  % selected type
mCat  = CatList{this.SelectedCategory+1}; % selected category

% [EOF]
