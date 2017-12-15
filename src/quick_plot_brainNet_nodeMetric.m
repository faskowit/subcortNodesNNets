function [ netFig ] = quick_plot_brainNet_nodeMetric(projectDir,dataChoice,nodeMetric,graphView,nodeSizeAddPair)
% will assume that the nodeMetric vector passed in will include NaNs where
% the node will be bad, and zeros where is should be white

% force nodeMetric to be column 
nodeMetric = nodeMetric(:);

% extract vector that only preserves NaN
badNodes = nodeMetric .* 0 ;

% length with NaNs
lenNodeMetric = length(nodeMetric);

% wantN = goodNodes(1:nNodes_noSubC) ;
% wantFdrPass = fdrPass(wantN) ;

nodeMetricNoNaN = nodeMetric(~isnan(nodeMetric)); 
noNaNnonZidx = nodeMetricNoNaN ~= 0;

%% first plot, underlay

underlay = quick_plot_brainNet(projectDir,dataChoice, ...
    ones(lenNodeMetric,1) + badNodes,[],graphView,nodeSizeAddPair(1)) ;

%% add colors to underlay nodes

lightGreyTri = [0.8 0.8 0.8] ;
darkGreyTri = [0.7 0.7 0.7] ;

% make outline color vector based on nonZero in nodeMetricNoNaN
outlineColorMat = repmat(lightGreyTri,length(nodeMetricNoNaN),1) ;
outlineColorMat(noNaNnonZidx,:) = repmat(darkGreyTri,sum(noNaNnonZidx),1) ;

% add the underlay color
underlay.NodeColor = outlineColorMat ;

%% hold up, wait a minute
hold
%% second plot, overlay

netFig = quick_plot_brainNet(projectDir,dataChoice,...
    ones(lenNodeMetric,1) + badNodes,[],graphView,nodeSizeAddPair(2)) ;

%% overlay colors

% initialize colors
nColors = zeros([ length(nodeMetricNoNaN) 3]);

% lets figure out if we want colorbar with one or two poles

% if min less than zero, and max is greater than zero...range incl zero 
% need to have multipolar colormap
if (min(nodeMetricNoNaN) < 0) && (max(nodeMetricNoNaN) > 0)

    cmap_range = max(nodeMetricNoNaN(noNaNnonZidx)) ...
        - min(nodeMetricNoNaN(noNaNnonZidx)) ;

    under0 = floor((abs(min(nodeMetricNoNaN(noNaNnonZidx))) ...
        / cmap_range) * 100)  ;
    over0 = floor((max(nodeMetricNoNaN(noNaNnonZidx)) ...
        / cmap_range) * 100) ;

    cmapUnder0 = flipud(brewermap(under0,'blues')) ;
    cmapOver0 = brewermap(over0,'reds') ;

    cmap = [ cmapUnder0 ;
             1 1 1 ;
             cmapOver0 ] ;

    % get the colors we want for the nodes
    % need to split up by neg and pos
    negWant_idx = nodeMetricNoNaN < 0 ;
    posWant_idx = nodeMetricNoNaN > 0 ;

    nColors(negWant_idx,:) = vals2colormap(nodeMetricNoNaN(negWant_idx),cmapUnder0);
    nColors(posWant_idx,:) = vals2colormap(nodeMetricNoNaN(posWant_idx),cmapOver0);
         
else
    % super simple yo    

    % just determin direction of colormap
    if max(nodeMetricNoNaN) <= 0
        %cmap = flipud(viridis(100)) ;
        cmap = flipud(brewermap(100,'YlGn'));
    else
        %cmap = viridis(100) ;
        cmap = brewermap(100,'YlGn') ;
    end
    
    nColors = vals2colormap(nodeMetricNoNaN,cmap);
end
     
whiteTri = [1 1 1];

% make the zero vals white
nColors(~noNaNnonZidx,:) = repmat(whiteTri,sum(~noNaNnonZidx),1) ;

% set the new colors!
netFig.NodeColor = nColors;

%% other plot stuff
% need to reset caxis min and max
caxis([min(nodeMetricNoNaN) max(nodeMetricNoNaN)])
colormap(cmap)
colorbar
