% The spikes are stored under each block for each probe separately.
%
% Here's an example of one spike block:
%
% Data for probe00:
% //znas/Subjects/CR017/2019-11-13/3/aligned2pxi/2019-11-13_3_CR017_probe00_info.hdf
%
% Data for probe01:
% //znas/Subjects/CR017/2019-11-13/3/aligned2pxi/2019-11-13_3_CR017_probe01_info.hdf
%
% For example, probe01 contains the following information:
%
% V1_clusterids (188,) int64 # the cluster IDs for neurons located in putative V1
% depths (484,) float64        # the depth of all clusters
% good_clusters (484,) bool # results of manual curation: if True, then that cluster is "good"
% nclusters (1,) int64 # total number of clusters in this probe
% spike_clusters (837148,) int32 # the cluster ID for each spike
% spike_times (837148,) float64 # the time of each spike aligned to the timeline onset.
%
% In the same directory, you'll also find the precise timeline times in the file
% "2019-11-13_3_CR017_timeline_aligned2pxi.hdf".
% This file contains the timeline signals original times "original_times",
% the more precise times "times" and the estimated sampling rate relative to
% the PXI "sample_ratehz".
%
% acqlive (498000,) int8
% flipper (498000,) int8
% original_times (498000,) float64
% sample_ratehz (1,) float64
% t0 (1,) float64
% times (498000,) float64
%
% You can basically ignore all of this though. As I mentioned, this basically
% amounts to less than a 1-2 ms difference over 10mins.  the relative
% differences between the "original times" and the aligned times is tiny.
% anyway, i just mention that here in case you wanna use these  slighly more
% precise aligned times.


probe00_filename = ...
    '//znas.cortexlab.net/Subjects/CR017/2019-11-13/3/aligned2pxi/2019-11-13_3_CR017_probe00_info.hdf';

probe01_filename = ...
    '//znas.cortexlab.net/Subjects/CR017/2019-11-13/3/aligned2pxi/2019-11-13_3_CR017_probe01_info.hdf';

probe00_info = h5info(probe00_filename);
probe01_info = h5info(probe01_filename);

%%
datasetNames = {probe00_info.Datasets.Name}';
data = struct;
for iDataset = 1:length(datasetNames)
    datasetName = datasetNames{iDataset};
    data.(datasetName) = hdf5read(probe00_filename, datasetName);
end
%%