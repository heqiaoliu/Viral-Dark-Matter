%REGEXPTRANSLATE Regular expression related string transformations
%   A = REGEXPTRANSLATE(OPERATION, B) Translates the string B using the
%   operation specified by OPERATION.  OPERATION can be one of the
%   following strings which will enable the corresponding translation.
%
%     'escape'   -- Escape all special characters in B such that regexp with A
%                   will match or replace as B literally.
%     'wildcard' -- Convert the wildcard string B to a regular expression (A)
%                   that will match the same strings.
%
%   REGEXPTRANSLATE supports international character sets.
%
%   See also REGEXP, REGEXPI, REGEXPREP.
%

%
%   J. Breslau
%   Copyright 1984-2006 The MathWorks, Inc.
%  $Revision: 1.1.8.2 $  $Date: 2005/12/12 23:26:49 $
%

