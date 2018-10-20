% this script deals with testing how the IQ demodulation works

fs = 200e6;
f =  20e6;
t0 = 0;
sigma = 1/f*5; % [sec] Will give a reasonabke number of cycles in a single pulse

dur = 1/550/5;
N = round(dur*fs/2);
t = (-N:N)/fs;
fAxis = linspace(-fs/2, fs/2, length(t));
oscillation = cos(2*pi*f*(t-t0));
envelope = exp(-(t-t0).^2/2/sigma^2);
pulse = oscillation.*envelope;


c = 1540; % [m/s]
lambda = c/f*1e6;
sprintf('Wavelength = %2.0f [um]\n', lambda)

demod = exp(-2*pi*f*t*1i);

figure
subplot(1, 2, 1)
plot(t, pulse)
subplot(1, 2, 2)
plot(fAxis, real(fftshift(fft(pulse))), fAxis, imag(fftshift(fft(pulse)))); 

demodPulse = pulse.*demod;
figure
subplot(1, 2, 1)
plot(t, real(demodPulse), t, imag(demodPulse))
dpf = fft(demodPulse);
subplot(1, 2, 2);
plot(fAxis, real(fftshift(dpf)), fAxis, imag(fftshift(dpf))) 
