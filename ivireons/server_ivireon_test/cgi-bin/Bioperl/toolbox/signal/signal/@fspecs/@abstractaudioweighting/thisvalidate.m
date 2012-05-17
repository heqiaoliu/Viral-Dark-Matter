function [isvalid, errmsg, msgid] = thisvalidate(this)
%THISVALIDATE   Validate the specs

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/16 06:41:51 $

isvalid = true;
errmsg  = '';
msgid   = '';

% If normalize frequency is true, warn and set the design Fs to the default Fs
% value. Otherwise, set the design Fs to the Fs specified by the user. The
% weighting standards specify attenuation values for specific frequency points
% in Hz. For this reason, the sampling frequency becomes a design parameter. 
if this.NormalizedFrequency,
     warning(generatemsgid('NormalizedFrequency'), ...
         ['When the ''NormalizedFrequency'' property is true, a sampling ',...
         'frequency of %g Hz is assumed.'],this.DefaultFs);
     
     this.ActualDesignFs = this.DefaultFs;          
else
    this.ActualDesignFs = this.Fs;
end

   
% [EOF]
