%GETOPTIONS  Get plot options from a plot
%
%  P = GETOPTIONS(H) returns the plot options P for a plot with 
%  handle H. 
%
%  For example:
%     h = bodeplot(rss(2));
%     p = getoptions(h);  % returns the Bode plot options object
%     p.MagVisible = 'off'; % change Bode plot options object
%     setoptions(h,p); % apply changes to the Bode plot
%
%  P = GETOPTIONS(H,PropertyName) returns the specified options property, 
%  for the plot with handle H. 
%
%  For example:
%     h = bodeplot(rss(2));
%     prop = getoptions(h,'MagVisible')
%
%  For a list of available properties for each type of plot options, type,
%  for example, "help bodeoptions".
%
%  See also WRFC/SETOPTIONS, BODEOPTIONS, HSVOPTIONS, NICHOLSOPTIONS,
%  NYQUISTOPTIONS, PZOPTIONS, SIGMAOPTIONS, TIMEOPTIONS.

%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:28:40 $
