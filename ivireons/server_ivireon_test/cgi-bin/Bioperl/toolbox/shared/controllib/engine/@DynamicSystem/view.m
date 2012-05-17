function [ViewFig,ViewObj] = view(varargin)
%VIEW  View dynamic system responses.
%
%   VIEW(SYS1,SYS2,...,SYSN) opens an LTI Viewer containing the step
%   response of the dynamic systems SYS1,SYS2,...,SYSN.  You can specify a
%   distinctive color, line style, and marker for each system, as in
%      sys1 = rss(3,2,2);
%      sys2 = rss(4,2,2);
%      view(sys1,'r-*',sys2,'m--');
%
%   VIEW(PLOTTYPE,SYS1,SYS2,...,SYSN) further specifies which responses 
%   to plot in the LTI Viewer. PLOTTYPE may be any of the following  
%   strings (or a combination thereof):
%      'step'           Step response
%      'impulse'        Impulse response
%      'bode'           Bode diagram
%      'bodemag'        Bode magnitude diagram
%      'nyquist'        Nyquist plot
%      'nichols'        Nichols plot
%      'sigma'          Singular value plot
%      'pzmap'          Pole/zero map
%      'iopzmap'        Pole/zero map for each I/O pair
%   For example, 
%      view({'step';'bode'},sys1,sys2)
%   opens an LTI Viewer showing the step and Bode responses of the LTI 
%   models SYS1 and SYS2.
%   
%   VIEW(PLOTTYPE,SYS,EXTRAS) lets you specify the additional input arguments 
%   supported by the various response types. See the help for each response 
%   type for more details on the format of these extra arguments. You can 
%   also use this syntax to show LSIM or INITIAL plots in the LTI Viewer, 
%   as in
%      view('lsim',sys1,sys2,u,t,x0)
%
%   H = VIEW(...) returns a handle to the LTI Viewer figure.
%
%   See also LTIVIEW, STEP, IMPULSE, LSIM, INITIAL, PZMAP, IOPZMAP, BODE, NYQUIST, NICHOLS, SIGMA. 

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:49:53 $
[hfig,ViewObj] = ltiview(varargin{:});
if nargout
   ViewFig = hfig;
end
