%
% Electrical impedance for bladder state classification:
% Data generatation script
% @author Eoghan Dunne.
%
% To work,the script requires:
% - the framework EIDORS(eidors3d.sourceforge.net)
% - Bladder shape sizes from the fitted equations given in 
%    Dunne, E., Mcginley, B., O'Halloran, M. & Porter, E. A Realistic Pelvic Phantom 
%    for Electrical Impedance Measurement. Physiological Measurement (2017), in review.
% - the function createCycSimData
%
%
% If you use any part of this work, please cite the relevant papers:
% - Bladder sizes from fitted equations:
%    Dunne, E., Mcginley, B., O'Halloran, M. & Porter, E. A Realistic Pelvic Phantom 
%    for Electrical Impedance Measurement. Physiological Measurement (2017), in review.
% - Scripts or any other relevant data/information
%    Dunne, E., Santorelli, A., Mcginley, B., Leader, G., O'Halloran, M. & Porter, E. Supervised Learning Classifiers for 
%    Electrical Impedance-based Bladder State Detection. Scientific Reports (2017), in review.
%


close all;
n_elecs = 32;

% load bladderRadiiForClassification - requried load bladder volume data
% based on source outlined in the header. Loaded data should have an array
% with the reference name of adultbladderShapeDims of size Lx3, where L is
% the number of bladder volumes.

stim =  mk_stim_patterns(n_elecs,1,[0,5],[0,5],{'no_meas_current'}, 0.005); % 5mA peak with a skip of 4.

adultBladderScalingFactor = 1/204.5; %mm^-1

backgroundCond = 0.2;
bladderCond = [0.5, 0.75, 1, 1.25, 1.50, 1.75, 2.00, 2.25, 2.50, 2.75, 3, 3.25, 3.5];
femHeight = 1;
maleFEMYRadius = 1;
maleFemXRadius = 0.57;
femaleFEMYRadius = 1.04;
femaleFEMXRadius = 0.55;

femDimZXY = [ ...
             femHeight, maleFemXRadius, maleFEMYRadius; ...
             femHeight, maleFemXRadius-maleFemXRadius*0.1, maleFEMYRadius; ...
             femHeight, maleFemXRadius+maleFemXRadius*0.1, maleFEMYRadius; ...
             femHeight, femaleFEMXRadius, femaleFEMYRadius; ...
             femHeight, femaleFEMXRadius-femaleFEMXRadius*0.1, femaleFEMYRadius; ...
             femHeight, femaleFEMXRadius+femaleFEMXRadius*0.1, femaleFEMYRadius; ...
             ];
meshDensity = 0.1;
elecDensity = 0.05;
bladderlocperc = 0.25;
bladderMidpt = 240; %ml;

scaledRadii = adultbladderShapeDims.*adultBladderScalingFactor;%scaling bladder down for male

fullBladderZHeight = scaledRadii(find(bladderVol == bladderMidpt),3); %taking radius as 240 ml Oc 13th

isHomogenousReq = 0;
simData = struct;

for boundaryNum = 1:size(femDimZXY,1);
    for bc = bladderCond
        for volIndex = 1:size(scaledRadii,1)
            bladderHeight = femHeight/2 - fullBladderZHeight + scaledRadii(volIndex,3);

            bladderLocation = [maleFemXRadius*bladderlocperc, 0, bladderHeight];
            ellipsoidRadii = scaledRadii(volIndex,:);

            simData.(genvarname(['FEMNo' int2str(boundaryNum)])).(genvarname(['bladderCond' int2str(bc*100)])).(genvarname(['bladderVol' int2str(bladderVol(volIndex)) 'ml'])) = createCycSimData(n_elecs, stim, [backgroundCond, bc], femDimZXY(boundaryNum,:), bladderLocation, ellipsoidRadii, isHomogenousReq, meshDensity, elecDensity);
        end
    end
end
simData.femDimZXYs = femDimZXY;
simData.backgroundCond = backgroundCond;
simData.bladderCond = bladderCond;
simData.bladderVol = bladderVol;
