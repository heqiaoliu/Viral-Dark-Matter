function [aa,bb,cc,dd] = connect(a,b,c,d,q,varargin)
%CONNECT  Block-diagram interconnections of dynamic systems.
%
%   CONNECT computes an aggregate model for a block diagram interconnection 
%   of dynamic systems. You can specify the block diagram connectivity in 
%   two ways:
%
%   Name-based interconnection
%     In this approach, you name the input and output signals of all blocks 
%     SYS1, SYS2,... in the block diagram, including the summation blocks. 
%     The aggregate model SYS is then built by 
%        SYS = CONNECT(SYS1,SYS2,...,INPUTS,OUTPUTS) 
%     where INPUTS and OUTPUTS are the names of the block diagram external 
%     I/Os (specified as strings or string vectors). For MIMO systems, use 
%     STRSEQ to quickly generate numbered channel names like {'e1';'e2';'e3'}.
%
%     Example 1: Given SISO LTI models C and G, you can construct the
%     closed-loop transfer T from r to y using
%
%                   e       u
%           r --->O-->[ C ]---[ G ]-+---> y
%               - |                 |       
%                 +<----------------+
%         
%        C.InputName = 'e';  C.OutputName = 'u';
%        G.InputName = 'u';  G.OutputName = 'y';
%        Sum = sumblk('e','r','y','+-');
%        T = connect(G,C,Sum,'r','y')
%
%     Example 2: If C and G above are two-input, two-output models instead, 
%     you can form the MIMO transfer T from r to y using
%         
%        C.InputName = {'e1','e2'};   C.OutputName = {'u1','u2'};
%        G.InputName = C.OutputName;  G.OutputName = {'y1','y2'};
%        r = {'r1','r2'};
%        Sum = sumblk(C.InputName,r,G.OutputName,'+-');
%        T = connect(G,C,Sum,r,G.OutputName)   
%
%   Index-based interconnection
%     In this approach, first combine all system blocks into an aggregate, 
%     unconnected model BLKSYS using APPEND. Then construct a matrix Q
%     where each row specifies one of the connections or summing junctions 
%     in terms of the input vector U and output vector Y of BLKSYS. For 
%     example, the row [3 2 0 0] indicates that Y(2) feeds into U(3), while 
%     the row [7 2 -15 6] indicates that Y(2) - Y(15) + Y(6) feeds into U(7).  
%     The aggregate model SYS is then obtained by 
%        SYS = CONNECT(BLKSYS,Q,INPUTS,OUTPUTS) 
%     where INPUTS and OUTPUTS are index vectors into U and Y selecting the   
%     block diagram external I/Os.
%
%     Example: You can construct the closed-loop model T for the block 
%     diagram above as follows:
%        BLKSYS = append(C,G);   
%        % U = inputs to C,G.  Y = outputs of C,G
%        % Here Y(1) feeds into U(2) and -Y(2) feeds into U(1)
%        Q = [2 1; 1 -2]; 
%        % External I/Os: r drives U(1) and y is Y(2)
%        T = connect(BLKSYS,Q,1,2)
%
%   Note: Blocks and states that are not connected to INPUTS or OUTPUTS are
%   automatically discarded.
%
%   See also SUMBLK, STRSEQ, APPEND, SERIES, PARALLEL, FEEDBACK, LFT,
%   DYNAMICSYSTEM.

%Old help
%CONNECT Connects unconnected block diagonal State Space system.
%   [Ac,Bc,Cc,Dc] = CONNECT(A,B,C,D,Q,INPUTS,OUTPUTS)  returns the 
%   state-space matrices (Ac,Bc,Cc,Dc) of a system given the block 
%   diagonal, unconnected (A,B,C,D) matrices and a matrix Q that 
%   specifies the interconnections.  The matrix Q has a row for each 
%   input, where the first element of each row is the number of the 
%   input.  The subsequent elements of each row specify where the 
%   block gets its summing inputs, with negative elements used to 
%   indicate minus inputs to the summing junction.  For example, if 
%   block 7 gets its inputs from the outputs of blocks 2, 15, and 6, 
%   and the block 15 input is negative, the 7'th row of Q would be 
%   [7 2 -15 6].  The vectors INPUTS and OUTPUTS are used to select 
%   the final inputs and outputs for (Ac,Bc,Cc,Dc). 
%
%   For more information see the Control System Toolbox User's Guide.   
%   See also BLKBUILD and CLOOP.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2010/03/31 18:13:16 $
%   J.N. Little 7-24-85
%   Last modified JNL 6-2-86
error(nargchk(5,7,nargin))
error(abcdchk(a,b,c,d));

[aa,bb,cc,dd] = ssdata(connect(ss(a,b,c,d),q,varargin{:}));
