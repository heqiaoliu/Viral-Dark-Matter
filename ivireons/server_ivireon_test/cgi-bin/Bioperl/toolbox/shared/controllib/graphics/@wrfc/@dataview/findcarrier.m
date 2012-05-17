function h = findcarrier(this)
%FINDCARRIER  Returns @waveform to which dataview component is attached.
%
%  Default implementation

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:29:00 $
h = findcarrier(this.Parent);