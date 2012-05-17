function [varargout] = statslibSubsrefRecurser(a,s)
%STATSLIBSUBSREFRECURSER Utility for overloaded statslib subsref methods.
[varargout{1:nargout}] = subsref(a,s);
