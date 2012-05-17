%SETOPTIONS  set plot properties
%
%  SETOPTIONS(H,P) applies the plot properties P to the plot with handle
%  H. 
% 
%  There are two ways to create a plot options handle:
% 
%  1)  Use GETOPTIONS, which accepts a plot handle and returns a plot
%      options handle. 
%        P = GETOPTIONS(H)
% 
%  2)  Create a default plot options handle using one of the following
%      commands: 
%        BODEOPTIONS -- Bode plots 
%        HSVOPTIONS -- Hankel singular values plots 
%        NICHOLSOPTIONS -- Nichols plots 
%        NYQUISTOPTIONS -- Nyquist plots 
%        PZOPTIONS -- Pole/zero plots 
%        SIGMAOPTIONS -- Sigma plots 
%        TIMEOPTIONS -- Time plots (step, initial, impulse, etc.) 
%
%  For example:
%     h = bodeplot(rss(2));
%     p = getoptions(h)
%     p.MagVisible = 'off';
%     setoptions(h,p);
%
%  SETOPTIONS(H,PropertyName,PropertyValue) applies the plot properties 
%  specified by the PropertyName and PropertyValue pairs to the plot with 
%  handle H. For a list of available properties for each type of plot
%  options, type, for example, "help bodeoptions".
%
%  For example:
%     h = bodeplot(rss(2));
%     setoptions(h,'MagVisible','off')
%
%  See also WRFC/GETOPTIONS, BODEOPTIONS, HSVOPTIONS, NICHOLSOPTIONS,
%  NYQUISTOPTIONS, PZOPTIONS, SIGMAOPTIONS, TIMEOPTIONS.

%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $   $Date: 2009/10/16 06:28:42 $