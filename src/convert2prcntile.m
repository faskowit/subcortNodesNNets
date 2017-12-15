function prcntileMat = convert2prcntile(mat)
% turn n x m into percentile, where percentile is within column

% get number of subj
n = size(mat,2);

% allocate
prcntileMat = zeros(size(mat));
for idx = 1:n
   
    [~,~,prcntileMat(:,idx)] = unique(mat(:,idx));    
end

% % divide by max ranking
prcntileMat = bsxfun(@rdivide,prcntileMat,max(prcntileMat)) ;