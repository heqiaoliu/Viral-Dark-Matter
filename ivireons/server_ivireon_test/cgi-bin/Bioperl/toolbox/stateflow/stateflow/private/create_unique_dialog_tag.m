function unique_tag = create_unique_dialog_tag(h, sentinel)

% Copyright 2005 The MathWorks, Inc.

    if nargin < 2
        sentinel = h.class;
    end
    unique_tag = ['_DDG_' sentinel '_Dialog_Tag_', sf_scalar2str(h.Id)];
