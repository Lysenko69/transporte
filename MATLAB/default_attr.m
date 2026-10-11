function attr = default_attr(edgecolor, edgewidth, label)
% DEFAULT_ATTR Crea la estructura de atributos de estilo para kmlwrite_polyline.
% Rellena todos los campos que la funcion necesita con valores por defecto.
% Los colores usan el formato KML aabbggrr (opacidad, azul, verde, rojo).
% Input (opcionales):
%   edgecolor = string, color de la linea (def. 'ff0000ff', rojo)
%   edgewidth = double, grosor de la linea (def. 3)
%   label     = string, etiqueta de la ruta en Google Earth (def. 'Route')
% Output:
%   attr = struct con los campos:
%       edgecolor   = string, color de la linea
%       edgewidth   = double, grosor de la linea (0 = no dibuja la linea)
%       extrude     = double, 1 une la linea con el suelo, 0 no
%       altmode     = string, 'clampToGround' o 'absolute'
%       label       = string, nombre de la ruta
%       iconscale   = double, tamano del icono de la etiqueta de ruta
%       iconurl     = string, URL del icono de la etiqueta de ruta
%       labelcolor  = string, color del texto de la etiqueta de ruta
%       labelscale  = double, tamano del texto de la etiqueta de ruta
%       wpiconscale = double, tamano del icono de cada fijo
%       wpiconurl   = string, URL del icono de cada fijo
%       wplabelcolor= string, color del nombre de cada fijo
%       wplabelscale= double, tamano del nombre de cada fijo

if nargin < 1, edgecolor = 'ff0000ff'; end
if nargin < 2, edgewidth = 3; end
if nargin < 3, label = 'Route'; end

attr.edgecolor    = edgecolor;
attr.edgewidth    = edgewidth;
attr.extrude      = 0;
attr.altmode      = 'clampToGround';
attr.label        = label;

% Etiqueta de la ruta (punto central)
attr.iconscale    = 0;      % icono oculto, solo se ve el texto
attr.iconurl      = 'http://maps.google.com/mapfiles/kml/shapes/triangle.png';
attr.labelcolor   = 'ffffffff';
attr.labelscale   = 1;

% Fijos
attr.wpiconscale  = 0.6;
attr.wpiconurl    = 'http://maps.google.com/mapfiles/kml/shapes/triangle.png';
attr.wplabelcolor = 'ffffffff';
attr.wplabelscale = 0.8;
end