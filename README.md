# fusiBox
Code related to fUSi rig and fUSi data analysis

## YStack class

### Properties

`ExpRef` - Unique experiment reference for the y-stack acquisition ('structural' stack of the whole accessible brain usually 
acquired once per experiment)  
`xAxis` - a vector of x coordinates in mm (along the ultrasound probe) of the pixels/voxels in the Doppler data  
`zAxis` - a vector of z coordinates in mm (away from the ultrasound probe - depth) of the pixels/voxels in the Doppler data  
`yAxis` - a vector of y coordinates in mm - position of the motor, which is moving the probe in the direction approximately 
orthogonal to a single x-z plane  
`boundingBox` - a structure with information about the useful range of x, y, and z coordinates - used for cropping data  
`mask` - additional mask (polygon) used to define non-rectangular region of interest for analysis - 
area outside of this mask will be 'zeroed' in the subsequent analyses  
`Doppler` - nZ-by-nX-by-nY array with the 'structural' brain image - useful for 3-D alignment across sessions, across animals, and to the atlas  
`BMode` - structural data acquired using B-Mode of ultrasound. Because of low ultrasoung contrast in the brain, not really useful  
`fusi` - an array of `Fus` objects (functional data) associated with the current `YStack` object  
`svd` - spatial components of the SVD decomposition (if was performed) of the **original** data (`U` and `S` of the `[U, S, V] = svds(doppler, nSVDs)`)  
`svdReg` - spatial components of the SVD decomposition (if was performed) of the **registered** data  
`regParams` - parameters used for registration (if performed by a proper method of YStack class)  

### Methods  

`YStack`  
`addFus`  
`addlistener`  
`applyMask`  
`autoCrop`  
`exportStruct`  
`getDoppler`  
`getMask`  
`getOutliers`  
`getRetinotopy`  
`getdII`  
`manualCrop`  
`plotSVDs`  
`plotSlices`  
`plotVolume`  
`plotVolumeMultiple`  
`processFastDoppler`  
`regDoppler`  
`renderVolumeRotation`  
`rotateUdII`  
`saveLite`  
`svdDecomposition`  
`svddII`  

---

## Fus class

### Properties

`ExpRef` - unique experiment reference  
`yStack` - handle to the associated `YStack`  
`doppler` - functional Doppler data - nZ-by-nX-by-nT  
`dopplerFast` - fast functional Doppler data - temporally subdivided `doppler`, average of N `dopplerFast` frames is equal to a single `doppler` frame  
`regDoppler` - registered `doppler`  
`regDopplerFast` - registered `dopplerFast`  
`xAxis` - x coordinates (in mm) of `doppler` and `dopplerFast` data. Can be different to the `xAxis` property of the associated `YStack` if the functional data is already cropped.  
`zAxis` - z (depth) coordinates (in mm) of `doppler` and `dopplerFast` data. Can be different to the `zAxis` property of the associated `YStack` if the functional data is already cropped.  
`yCoord` - the y coordinate in mm of the slice from YStack where the functional data was acquired  
`tAxis` - timestamps of **onsets** of `doppler` frames  
`tAxisFast` - timestamps of **onsets** of `dopplerFast` frames  
`dt` - **duration** of the `doppler` frame ('exposure time'). **Important to note** - this is not a usual sampling time, as in this system the sampling might not be uniform  
`dtFast` - **duration** of the `dopplerFast` frame. Also, read the note in `dt` property above  
`protocol` - mpep experimental protocol file (TODO explanation on mpep required here, but this is a long topic)  
`block` - block file generated by expServer (for MC experiments, more information might be available here https://github.com/cortex-lab/Rigbox at some point)  
`pars` - stimulus parameters (the exact contents depends on what experiment was performed)  
`TL` - Timeline structure (Timeline is part of https://github.com/cortex-lab/Rigbox)  
`hwInfo` - hardware information (mostly about the visual stimulus apparatus)  
`stim` - a preprocessed `protocol` to make more sence of the stimuli presented, might not always be correctly preprocessed, needs manual verification  
`stimTimes` - timestamps of stimulus presentations. The exact format depends on the type of experiment performed, but in general will have stimulus onset and offset times (not individual frames)  
`stimFrameTimes` - for mpep expeiments only - times of individual frames (textures in `stim`) acquired by a photodiode attached to the monitor and reading the 'sync square'  
`stimSequence` - for MC experiments only - the sequence of stimuli (what contrast, azimuth, amplitude etc. was the stimulus on every trial). Exact structure depends on the experiment type. Should be used together with `stimTimes`  
`eyeMovie` - VideoReader object of the eye-tracking movie  
`eyeTimes` - timestamps of the frames of the `eyeMovie`  

The following properties will only be populated after additional analyses:


`outlierFrameIdx` - `doppler` frames identified as outliers (usually due to motion artifacts)  
`outlierFrameIdxFast` - `dopplerFast` frames identified as outliers (usually due to motion artifacts)  
`dII` - _dI/I0_ of `doppler`  
`dIIFast` - _dI/I0_ of `dopplerFast`  
`regDII` - _dI/I0_ of `regDoppler`    
`regDIIFast` - _dI/I0_ of `regDopplerFast`    
`retinotopyMaps` - retinotopy maps calculated form `doppler` (or `regDoppler` if registration was performed)  
`retinotopyMapsFast` - retinotopy maps calculated form `dopplerFast` (or `regDopplerFat` if registration was performed)  
`svd` - temporal components of the SVD decomposition (`V` from the `[U, S, V] = svds(doppler, nSVDs)`) of the original `doppler` and `dopplerFast`  
`svdReg` - temporal components of the SVD decomposition of the registered `regDoppler` and `regDopplerFast`  
`D` - estimated displacement fields used for registration (see also MATLAB's `imregdemons()`)  

### Methods

`Fus`  
`addlistener`  
`dIIMovie`  
`getCroppedDoppler`  
`getETA`  
`getOutliers`  
`getRetinotopy`  
`getdII`  
`hardCrop`  
`movie`  
`projectFastDoppler`  
`regFastDoppler`  
`showRetinotopy`  

