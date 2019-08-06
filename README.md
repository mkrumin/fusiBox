# fusiBox
Code related to fUSi rig and fUSi data analysis

## Properties of YStack class

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
`svd` - spatial components of the SVD decomposition (if was performed) of the **original** data  
`svdReg` - spatial components of the SVD decomposition (if was performed) of the **registered** data  
`regParams` - parameters used for registration (if performed by a proper method of YStack class)  

