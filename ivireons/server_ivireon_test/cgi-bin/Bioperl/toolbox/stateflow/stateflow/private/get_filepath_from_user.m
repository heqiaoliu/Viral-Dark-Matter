function filepath = get_filepath_from_user(name, title)
%GET_FILEPATH_FROM_USER(NAME, TITLE)
%   FILEPATH = GET_FILEPATH_FROM_USER(NAME, TITLE)
%

%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.3.2.2 $  $Date: 2008/12/01 08:06:10 $
%
%
    [file, dir] = uiputfile(name, title);
    filepath = [dir filesep file];

