function cm = bwrColormap(pow)

if nargin < 1
    pow = 0.5;
end

% create a blue-white-red colormap with white == 0
r = [linspace(0, 1, 32), ones(1, 32)]';
g = [linspace(0, 1, 32), linspace(1, 0, 32)]';
b = flipud(r);
% (colormap).^(1/n) will make the white region wider
cm = ([r, g, b]).^(pow);
