% ---------------------------------------------------------------------
% Comprobacion contra los valores de la tabla (derrota en grados, dist en NM)
% ---------------------------------------------------------------------
fprintf('%-6s %-6s %8s %8s %6s %8s %8s %6s\n', 'Desde', 'Hasta', ...
        'trk_calc', 'trk_tab', 'dTrk', 'd_calc', 'd_tab', 'dDist');
for i = 1:N-2
    fprintf('%-6s %-6s %8.1f %8.1f %6.1f %8.2f %8.2f %6.2f\n', wp(i).name, wp(i+1).name, ...
            wp(i).track, D{i,6}, wp(i).track - D{i,6}, ...
            wp(i).dist,  D{i,7}, wp(i).dist  - D{i,7});
end
fprintf('Distancia total en-ruta: %.2f NM\n', wp(N-1).Total_dist);