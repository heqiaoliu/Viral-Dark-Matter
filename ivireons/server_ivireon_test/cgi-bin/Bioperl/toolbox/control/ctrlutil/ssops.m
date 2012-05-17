function [a,b,c,d,e]=ssops(op,a1,b1,c1,d1,e1,a2,b2,c2,d2,e2)
%SSOPS  Basic interconnection operations on state-space models.

%	Pascal Gahinet  5-9-97
%	Copyright 1986-2005 The MathWorks, Inc. 
%	$Revision: 1.12.4.1 $  $Date: 2005/11/15 00:56:39 $

% RE: No dimension checking + assumes empty matrices
%     correctly dimensioned
[ny1,nu1] = size(d1);  nx1 = size(a1,1);
[ny2,nu2] = size(d2);  nx2 = size(a2,1);

switch op, 
   case 'add'
      % Addition (parallel)
      a = [a1 zeros(nx1,nx2) ; zeros(nx2,nx1) a2];
      b = [b1 ; b2];
      c = [c1 , c2];
      d = d1 + d2;
      
   case 'mult'
      % Multiplication (series sys1*sys2)
      %     [ a1  b1*c2 ]       [ b1*d2 ]
      % A = [  0    a2  ]   B = [   b2  ]
      %
      % C = [ c1  d1*c2 ]   D =  d1*d2
      a = [a1 , b1*c2 ; zeros(nx2,nx1) , a2];
      b = [b1*d2 ; b2];
      c = [c1 , d1*c2];
      d = d1 * d2;
      
   case 'vcat'
      % Vertical concatenation
      %     [ a1  0 ]       [ b1 ]
      % A = [  0 a2 ]   B = [ b2 ]
      %
      %     [ c1  0 ]       [ d1 ]
      % C = [  0 c2 ]   D = [ d2 ]
      a = [a1 zeros(nx1,nx2) ; zeros(nx2,nx1) a2];
      b = [b1 ; b2];
      c = [c1 zeros(ny1,nx2) ; zeros(ny2,nx1) c2];
      d = [d1 ; d2];
      
   case 'hcat'
      % Horizontal concatenation
      %     [ a1  0 ]       [ b1  0 ]
      % A = [  0 a2 ]   B = [  0 b2 ]
      %
      % C = [ c1 c2 ]   D = [ d1 d2]
      a = [a1 zeros(nx1,nx2) ; zeros(nx2,nx1) a2];
      b = [b1 zeros(nx1,nu2) ; zeros(nx2,nu1) b2];
      c = [c1 , c2];
      d = [d1 , d2];
      
   case 'append'
      %     [ a1  0 ]       [ b1  0 ]
      % A = [  0 a2 ]   B = [  0 b2 ]
      %
      %     [ c1  0 ]       [ d1   0]
      % C = [  0 c2 ]   D = [  0  d2]
      a = [a1 zeros(nx1,nx2) ; zeros(nx2,nx1) a2];
      b = [b1 zeros(nx1,nu2) ; zeros(nx2,nu1) b2];
      c = [c1 zeros(ny1,nx2) ; zeros(ny2,nx1) c2];
      d = [d1 zeros(ny1,nu2) ; zeros(ny2,nu1) d2];
      
end

% E matrix
if nargout>4
   if isempty(e1)
      if isempty(e2)
         e = [];
      else
         e = [eye(nx1) zeros(nx1,nx2) ; zeros(nx2,nx1) e2];
      end
   else
      if isempty(e2)
         e = [e1 zeros(nx1,nx2) ; zeros(nx2,nx1) eye(nx2)];
      else
         e = [e1 zeros(nx1,nx2) ; zeros(nx2,nx1) e2];
      end
   end
end
