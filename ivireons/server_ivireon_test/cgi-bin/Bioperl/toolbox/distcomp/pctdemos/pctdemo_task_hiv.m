function D = pctdemo_task_hiv(Aseq, Bseq, bf)
%PCTDEMO_TASK_HIV A vectorizing wrapper function around seqpdist.
%   The function allows the calculations of distances between multiple pairs of 
%   GAG sequences in one function call.  The function seqpdist is vectorized, 
%   but in a different manner from what we need here.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:05:53 $
    
    numSequences = length(Aseq);
    D = zeros(numSequences, 1);
    
    % For each input pair (Aseq(i), Bseq(i)), 
    % we call |seqpdist| to align the GAG sequences and use the 'Tajima-Nei'
    % metric to measure the distances between them. 
    for i = 1:numSequences
        seqs(1).Sequence = Aseq(i).Sequence;
        seqs(2).Sequence = Bseq(i).Sequence;
        D(i) = seqpdist(seqs, 'method', 'Tajima-Nei', 'opt', bf, ...
                        'Alphabet', 'NT', 'indel', 'pair');
    end
end % End of pctdemo_task_hiv.
