function h = remezoptionsframe(varargin)
%REMEZOPTIONSFRAME  Constructor for the remez options frame
%   REMEZOPTIONSFRAME(DENSITY, NAME)
%   DENSITY   -   The density factor to start with
%   NAME      -   The name to use for the frame, if not needed set as empty
%   The input arguments can be specified in any order

%   Author(s): Z. Mecklai
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2003/03/02 10:28:18 $

% Call builtin constructor
h = siggui.remezoptionsframe;

settag(h);

% [EOF]
