function pctdemo_plot_hiv(fig, pold, description)
%PCTDEMO_PLOT_HIV Create the graphs for the Parallel Computing Toolbox
%Gene Sequence Alignment demo.
%   pctdemo_plot_hiv(fig, gagd, pold, envd, description) displays the
%   phylogenetic trees based on the specified distances.
%   
%   pold measures the distance between the POL polyprotein sequences.
%   
%   description is the virus description obtained from pctdemo_setup_hiv.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:05:33 $
    
    % Phylogenetic tree reconstruction
    %
    % The *seqpdist* and *seqlinkage* commands are used to construct a
    % phylogenetic tree for the POL coding region using the Tajima-Nei
    % method to measure the distance between the sequences and the
    % unweighted pair group method using arithmetic averages, or UPGMA
    % method, for the hierarchical clustering. The Tajima-Nei method is
    % only defined for nucleotides, therefore nucleotide sequences are used
    % rather than the translated amino acid sequences. The distance
    % calculation is very computationally intensive. 
    % 
    % Note: The distance has been calculated in the Parallel Computing
    % Toolbox Gene Sequence Aligment demos, and is passed as the pold
    % parameter to this function. 
    %
    
    poltree = seqlinkage(pold, 'WPGMA', description);

    % Calling plot on a phylogenetic tree always opens a new figure, so we 
    % cannot use the input argument fig here.
    h = plot(poltree, 'type', 'angular');
    ax = h.axes;
    fig = get(ax, 'parent');
    set(fig, 'Name', 'Analysis of the Origin of HIV');
    title(ax, 'Immunodeficieny virus (POL polyprotein)')
    xlabel(ax, 'Patristic distance');
    
    % Analyzing the origins of the HIV virus from the plot
    %
    % Please note that not all the viruses are used for the computations
    % at the default difficulty level.  If you run this demo at a sufficiently 
    % high difficulty level, all the viruses will be included in the 
    % distance calculations and the following discussion applies.
    %
    % The phylogenetic tree resulting from our analysis illustrates the
    % presence of two clusters and some other isolated strains. The most
    % compact cluster includes all the HIV2 samples; at the top branch of
    % this cluster we observe the sooty mangabey which has been identified
    % as the origin of this lentivirus in humans. The cluster containing
    % the HIV1 strain, however is not as compact as the HIV2 cluster. From
    % the tree it appears that the Chimpanzee is the source of HIV1,
    % however, the origin of the cross-species transmission to humans is
    % still a matter of debate amongst HIV researchers. 

end % End of pctdemo_plot_hiv.
