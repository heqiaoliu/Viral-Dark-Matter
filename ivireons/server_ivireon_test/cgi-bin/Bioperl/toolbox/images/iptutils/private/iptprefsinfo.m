function pref_info = iptprefsinfo
%IPTPREFSINFO Image Processing Toolbox preference information.
%   IPTPREFSINFO returns a 3-column cell array containing information
%   about each Image Processing Toolbox preference.  Each row contains
%   information about a single preference.  
%   
%   The first column of each row contains a cell array with a maximum of
%   two elements.  The first element indicates the current preference name
%   and the second element, if it exists, indicates the obsoleted
%   preference name.  If the first element is empty this indicates that the
%   preference has simply been obsoleted without a replacement.
%   
%   The second column of each row is a cell array containing the set of
%   acceptable values for that preference setting.  An empty cell array
%   indicates that the preference does not have a fixed set of values.
%
%   The third column of each row contains a single-element cell array
%   containing the default value for the preference.  An empy cell array
%   indicates that the preference does not have a default value.
%
%   See also IPTSETPREF, IPTGETPREF, IPTPREFS.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/26 14:25:33 $


OBSOLETE = '';
pref_info = { ...
    {'ImshowBorder'},               {'tight'; 'loose'},         {'loose'}
    {'ImshowAxesVisible'},          {'on'; 'off'},              {'off'}
    {'ImshowInitialMagnification',...
     'ImshowTruesize'},             {100; 'fit'},               {100}
    {OBSOLETE,...
     'TruesizeWarning'}             {'on'; 'off'},              {'on'}
    {'ImtoolStartWithOverview'},    {true; false},              {false}
    {'ImtoolInitialMagnification',...
    'ImviewInitialMagnification'},  {100; 'fit' ; 'adaptive' }, {'adaptive'}
    {'UseIPPL'},                    {true; false},              {true}
  };

        
