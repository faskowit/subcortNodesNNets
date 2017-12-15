function [ comVec , comVec_Q , Qzscore ] = quick_sweep_mod(CIJ,gRange)
% simple function to return quick consensus mod, using the functions of BCT

if nargin < 2
    gRange = 0.1:0.005:2.5 ;
end

nNodes = size(CIJ,1);

% first lets sweep gamma
comsAcrossG = zeros([nNodes length(gRange)]);
for idx = 1:length(gRange)
   
    comsAcrossG(:,idx) = community_louvain(CIJ,gRange(idx));
end

% get the num coms that had the largests plateau
% get num coms at each sweep iteration 
numComsAcrossG = max(comsAcrossG)' ;

% get the diff in vector, to get start and end of the chunks
startInd = [1 ; diff(numComsAcrossG)] ~= 0 ;
endInd = [diff(numComsAcrossG); 1] ~= 0 ;

% get the indicies of this start and end points
startInd2 = find(startInd);
endInd2 = find(endInd);

% subtract end-start ind to get size of chunk (subtract 1 from start ind2
% to get actual sizes of groups)
[platSize,maxIdx] = max(endInd2 - (startInd2-1));

% get the largest plateau, backtrack to numComs
% plateau_numComs = numComsAcrossG(startInd2(maxIdx));
plat_start = startInd2(maxIdx) ;
plat_end = endInd2(maxIdx) ;

% find the runs thar
plat_gamma = gRange(plat_start:plat_end) ;

% % run close to 1000 iterations with these gammas
% cnsnsIters = (1000 - mod(1000,platSize)) ./ platSize ;

plat_coms_subset = comsAcrossG(:,plat_start:plat_end);

% find parition in plateau most representative
plat_vi_mat = zeros(platSize) ;
for idx = 1:platSize
   for jdx = 1:platSize
       
       plat_vi_mat(idx,jdx) = partition_distance(plat_coms_subset(:,idx),...
           plat_coms_subset(:,jdx)) ;
   end
end

% the min of the sum across rows gives us centroid
[~,minViIdx] = min(sum(plat_vi_mat)) ;

% get the gamma of the centroid
use_gamma = plat_gamma(minViIdx) ;

% use the found gamma and squeeze any extra modularity outta it
% Iterative community finetuning.
% W is the input connection matrix.
Q0 = -1; Q1 = 0;            % initialize modularity values
while Q1-Q0>1e-5;           % while modularity increases
  Q0 = Q1;                % perform community detection
  [M, Q1] = community_louvain(CIJ, use_gamma);
end

% return
comVec = M ;
comVec_Q = Q1 ;

%% additional zscore calculation
if nargout > 2
   
    % num iterations
    numIters = 500 ;
    
    % lets get a q distribution 
    tmpQDist = zeros([numIters 1]);
    
    for idx = 1:numIters
        
        % disp(idx)
        
        % get a randomized graph, rewire ~10%
        randCIJ = randomize_graph_partial_und(CIJ,...
            zeros(size(CIJ)),floor(sum(sum(CIJ > 0)) ./ 25)) ;
        [~,tmpQDist(idx)] = community_louvain(randCIJ, use_gamma) ;
        
    end
    
    % then measure the zscore of the observed q vs. the rand dist
    zscoreDist = zscore([comVec_Q ; tmpQDist ]) ;
    
end

Qzscore = zscoreDist(1) ;



