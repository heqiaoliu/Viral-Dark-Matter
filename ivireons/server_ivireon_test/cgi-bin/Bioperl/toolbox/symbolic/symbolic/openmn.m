function nb = openmn(file)
%OPENMN Open MuPAD notebook
%   NB = OPENMN(FILE) opens the MuPAD notebook named FILE and returns
%   a notebook object NB
%
%   See also OPEN, MUPAD

%  Copyright 2008 The MathWorks, Inc

nb = mupad(file);
