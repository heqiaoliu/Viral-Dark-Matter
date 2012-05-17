function updatestyle(this,varargin)
%UPDATESTYLE  Updates wave styles when style preferences change.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $ $Date: 2004/12/26 21:43:23 $

%% Overloaded updatestyle directly assigns waveform style rather than
%% calling applystyle since the @waveform applystyle does not write the new
%% Style object to the waveform's style property. TO DO: Discuss
%% @waveform/applystyle with John
Styles = this.StyleManager.Styles;
Nr = length(this.Waves);
Ns = length(Styles);
for ct=1:Nr
    this.Waves(ct).Style = Styles(1+rem(ct-1,Ns));
end