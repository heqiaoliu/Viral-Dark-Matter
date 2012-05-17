function out = applycformsequence(in, cforms)
%APPLYCFORMSEQUENCE Apply a sequence of cforms.
%   OUT = APPLYCFORMSEQUENCE(IN, CFORMS) applys a sequence of cforms to
%   the input data, IN.  CFORMS is a cell array containing the cform
%   structs.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/04/03 03:10:06 $

out = in;
for k = 1:length(cforms)
    out = applycform(out, cforms{k});
end
