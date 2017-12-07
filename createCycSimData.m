%
% Electrical impedance for bladder state classification:
% Data generatation script
% @author Eoghan Dunne.
%
% To work,the script requires:
% - the framework EIDORS(eidors3d.sourceforge.net)
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

function simData = createCycSimData(n_elecs, stim, cond, femDimZXY, bladderLocation, ellipsoidRadii, isHomogenousReq, meshDensity, elecDensity)


    bladderDefn = sprintf('%s %0.5f, %0.5f, %0.5f; %0.5f, 0, 0; 0, %0.5f,0; 0, 0, %0.5f);','solid bladder = ellipsoid (', bladderLocation(1), bladderLocation(2), bladderLocation(3), ellipsoidRadii(1), ellipsoidRadii(2), ellipsoidRadii(3));

    extra = {'bladder', bladderDefn};
    [fmdl,midx] = ng_mk_ellip_models([femDimZXY(1), femDimZXY(2), femDimZXY(3),meshDensity] ,[n_elecs,femDimZXY(1)/2],[elecDensity],extra);
    fmdl.stimulation =  stim;

    img = mk_image(fmdl,cond(1));

    if isHomogenousReq
        vh = fwd_solve(img);
        simData.vh = vh;
    end

    img.elem_data(midx{2}) = cond(2);

    vi = fwd_solve(img);
    
    simData.img = img;
    simData.vi = vi;

end