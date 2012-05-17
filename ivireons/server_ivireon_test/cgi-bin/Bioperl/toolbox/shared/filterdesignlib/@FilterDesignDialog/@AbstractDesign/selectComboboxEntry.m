function selectComboboxEntry(this,hdlg, indx, prop, options)   %#ok<INUSL>
%SELECTCOMBOBOXENTRY Select the combobox entry

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/04/21 04:21:21 $

set(this, prop, options{indx+1});

% [EOF]
