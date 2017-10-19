
%% simulation and analysis test
% figuring out how to deal with all the wrapping and mod(..., 2pi) for the
% phase estimation

prefPosVec = [-135:135]; % [deg]
hemoDelay = 1; % [sec]
posStart(1) = -135;
posEnd(1) = 135;
posStart(2) = 135;
posEnd(2) = -135;
f = 0.12;
nCycles = 6;
tStart = 0;
dt = 0.5;
nSamples = nCycles/f/dt;
t = tStart + (0:nSamples-1)*dt;

for iPos = 1:length(prefPosVec)
    prefPos = prefPosVec(iPos);
    phi1(iPos) = (prefPos-posStart(1))/(posEnd(1)-posStart(1))*2*pi;
    phi2(iPos) = (prefPos-posStart(2))/(posEnd(2)-posStart(2))*2*pi;
%     sigRef = cos(2*pi*f*t);
    sig1 = cos(2*pi*f*(t - hemoDelay) - phi1(iPos)) + 0.1*randn(size(t));
    sig2 = cos(2*pi*f*(t - hemoDelay) - phi2(iPos)) + 0.1*randn(size(t));
%     figure
%     plot(t, sigRef, 'k', t, sig1, 'c', t, sig2, 'r')
%     legend('ref', 'LtoR', 'RtoL');
    
    sf1 = fft(sig1);
    phiEst1(iPos) = -angle(sf1(nCycles+1));
    sf2 = fft(sig2);
    phiEst2(iPos) = -angle(sf2(nCycles+1));

    hemoPhaseEst(iPos) = mod(phiEst1(iPos)+phiEst2(iPos), 2*pi)/2;
    hemoDelayEst(iPos) = hemoPhaseEst(iPos)/(2*pi)/f;
    
    phiEst1(iPos) = mod(phiEst1(iPos) - hemoPhaseEst(iPos), 2*pi);
    phiEst2(iPos) = mod(phiEst2(iPos) - hemoPhaseEst(iPos), 2*pi);
    prefPhase(iPos) = (phiEst1(iPos) + 2*pi - phiEst2(iPos))/2;
    prefPosEst(iPos) = (posEnd(1)-posStart(1))*prefPhase(iPos)/(2*pi) + posStart(1);
end

figure
plot(prefPosVec, phi1, 'b', 'LineWidth', 2);
hold on;
plot(prefPosVec, phiEst1, '--', 'Color', [0.5 0.5 1], 'LineWidth', 2)
plot(prefPosVec, phi2, 'r', 'LineWidth', 2);
plot(prefPosVec, phiEst2, '--', 'Color', [1 0.5 0.5], 'LineWidth', 2)
hPh = mod((phiEst1+phiEst2), 2*pi)/2;
plot(prefPosVec, hPh, '--k', 'LineWidth', 2)
plot(prefPosVec, (mod(phiEst1-hPh, 2*pi) + 2*pi-mod((phiEst2-hPh), 2*pi))/2, 'oc', 'LineWidth', 2)

% plot(prefPosVec, prefPosEst, '.-')
