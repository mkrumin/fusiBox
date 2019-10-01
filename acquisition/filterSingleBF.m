function frameOut = filterSingleBF(bf)

bfIm = imag(bf);
bfRe = real(bf);

[b, a] = butter(3, 15/250, 'high');

bfIm = filter(b, a, bfIm);
bfRe = filter(b, a, bfRe);

bfIm = shiftdim(bfIm, 1);
bfRe = shiftdim(bfRe, 1);

bfIm = rmSVD(bfIm, 50);
bfRe = rmSVD(bfRe, 50);

frameOut = mean(bfRe.^2 + bfIm.^2, 3);
