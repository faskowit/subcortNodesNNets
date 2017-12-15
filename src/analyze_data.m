function [] = analyze_data(projectDir,dataChoice,netStruct)
% analyze some results!

%% setup some vars

nNodes_full = size(netStruct.degree.full,1);
nNodes_noSubC = size(netStruct.degree.noSubC,1);

% nodes we dont want, cause they are empty
badNodes = double(sum(netStruct.degree.full,2) == 0) ;
goodNodes = ~badNodes;
badNodes(~~badNodes) = NaN ;

%% setup nodeMetric vars

nodeMetricTypes = { 'degree' 'bdegree' 'kcore' 'btwn' 'eff' } ;

nM_diff = cell([length(nodeMetricTypes) 1]);
nM_diff_mean = cell([length(nodeMetricTypes) 1]);
nM_diff_pvals = cell([length(nodeMetricTypes) 1]);

% vector to store crit vals
nM_diff_pFDRcrit = zeros([length(nodeMetricTypes) 1]);

%% iterate over node metrics!

for idx = 1:length(nodeMetricTypes)

    % get the nodes of the full, but only the non-subcort nodes
    tmpStat_full = convert2ranking(netStruct.(nodeMetricTypes{idx}).full(1:nNodes_noSubC,:)) ;
    % get all the nodes here, subcort already excluded
    tmpStat_noSubC = convert2ranking(netStruct.(nodeMetricTypes{idx}).noSubC) ;
    
    % get the difference
    nM_diff{idx} = tmpStat_full - tmpStat_noSubC ;

    % get the mean difference
    tmpStat_mean = mean(nM_diff{idx},2);
    nM_diff_mean{idx} = tmpStat_mean + badNodes(1:nNodes_noSubC) ; 
    
end
    
%% ttests!

for idx = 1:length(nodeMetricTypes)

    % do a test at each node (row)
    tmpPvals = ones([length(nM_diff_mean{idx}) 1]) ;
    for jdx = 1:size(tmpPvals,1)

        [~,tmpPvals(jdx)] = ttest(nM_diff{idx}(jdx,:)) ;
    end

    nM_diff_pFDRcrit(idx) = FDR(tmpPvals,0.001) ;
    
%     tmpPvals_thr = (tmpPvals <= d_diff_critP) ;

    nM_diff_pvals{idx} = tmpPvals ;
    
end

%% plot it

path2figs = strcat(projectDir,'/results/');
mkdir(path2figs)

% quick_plot_brainNet_nodeMetric(projectDir,dataChoice,nodeMetric,graphView,nodeSizeAddPair)

for idx = 1:length(nodeMetricTypes)

    plotData = nM_diff_mean{idx} ;

    % where data pval was above crit... set to 0!
    plotData(nM_diff_pvals{idx} > nM_diff_pFDRcrit(idx)) = 0 ;

    % the figure
    fig = quick_plot_brainNet_nodeMetric(projectDir,dataChoice,plotData,'h',[12 10]);
    
    % do some title stuff
    title(strcat('Full vs noSubC',{' '},nodeMetricTypes{idx},' rank diff'))
    ylabel('right')
    xlabel('posterior')
    cb = colorbar;
    ylabel(cb,'Mean rank difference')
    
    % save fig!!!
    fig_output = fullfile(path2figs,sprintf('nodeMetricDiff_%s_%s_%s',dataChoice,'h',nodeMetricTypes{idx}));
    set(gcf,'paperpositionmode','auto');
    print(gcf,'-dpng','-r300',fig_output);

    close(gcf)
end



