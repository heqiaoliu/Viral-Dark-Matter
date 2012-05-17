function set_frequencyconstraints(this, oldFreqConstraints)
%SET_FREQUENCYCONSTRAINTS   PostSet function for the 'frequencyconstraints' property.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/21 04:23:16 $

%If previous FreqConstraints correspond to a shelving filter design, and
%new FreqConstraints do not correspond to a shelf design, then force
%this.Fdesign.F0 to a nonzero/nonunity value. F0 will still be set
%according to what exists in this.F0 which corresponds to the user's input.
%Setting this.Fdesign.F0 to a non zero value will avoid an error when
%setting the specs in setupFDesign.m 
if strncmp(oldFreqConstraints,'Shelf type',10) && ...
    ~strncmp(this.FrequencyConstraints,'Shelf type',10)
    this.Fdesign.F0 = .5; 
end

updateMagConstraints(this);

% [EOF]

