function this = algorithmoptions
% class to support property inspector for Algorithm Options; it is an
% abstract class; see algorithmoptionswithfocus and algorithmoptionswithx0
% concrete classes

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/05/19 23:04:22 $

this = nloptionspack.algorithmoptions;

nloptionspack.utConfigureAlgorithOptionsObject(this);
