function prtFeatSelector = prtFeatSelGenSfs(DS,PrtFeatSelOpt)
%prtFeatSelector = prtFeatSelGenSfs(DS,PrtFeatSelOpt,PrtWrapperOpt)

nFeats = DS.nDimensions;

sfsPerformance = zeros(min(nFeats,PrtFeatSelOpt.nFeatures),1);
sfsSelectedFeatures = [];

for j = 1:min(nFeats,PrtFeatSelOpt.nFeatures);
    
    if PrtFeatSelOpt.showProgressBar
        h = waitbar(0,sprintf('SFS: Processing Feature %d Out Of %d',j,min(nFeats,PrtFeatSelOpt.nFeatures)));
    end
    
    availableFeatures = setdiff(1:nFeats,sfsSelectedFeatures);
    performance = nan(size(availableFeatures));
    for i = 1:length(availableFeatures)
        currentFeatureSet = cat(2,sfsSelectedFeatures,availableFeatures(i));
        tempDataSet = prtDataSetLabeled(DS.data(:,currentFeatureSet),DS.dataLabels);
        performance(i) = PrtFeatSelOpt.EvaluationMetric(tempDataSet);
        
        if PrtFeatSelOpt.showProgressBar
            waitbar(i/length(availableFeatures),h);
        end
    end
    
    if PrtFeatSelOpt.showProgressBar
        close(h);
    end
    
    % Randomly choose the next feature if more than one provide the same performance
    [val,newFeatInd] = max(performance);
    newFeatInd = find(performance == val);
    newFeatInd = newFeatInd(max(1,ceil(rand*length(newFeatInd))));
    % In the (degenerate) case when rand==0, set the index to the first one
    
    sfsPerformance(j) = val;
    sfsSelectedFeatures(j) = [availableFeatures(newFeatInd)];
end
prtFeatSelector.performance = sfsPerformance;
prtFeatSelector.selectedFeatures = sfsSelectedFeatures;
prtFeatSelector.PrtOptions = PrtFeatSelOpt;