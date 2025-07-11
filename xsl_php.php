<?php
/**
 * Uso:
 *   php procesa_xsl.php archivo.xml transformacion.xsl [salida.html]
 */

// Comprueba argumentos
if ($argc < 3) {
    echo "Uso: php procesa_xsl.php archivo.xml transformacion.xsl [salida.html]\n";
    exit(1);
}

$xmlFile = $argv[1];
$xslFile = $argv[2];
$outputFile = $argv[3] ?? null;

// 1. Cargar XML
$xml = new DOMDocument;
if (!$xml->load($xmlFile)) {
    echo "Error: No se pudo cargar el XML ($xmlFile)\n";
    exit(1);
}

// 2. Cargar XSL
$xsl = new DOMDocument;
if (!$xsl->load($xslFile)) {
    echo "Error: No se pudo cargar el XSL ($xslFile)\n";
    exit(1);
}

// 3. Crear procesador XSLT
$proc = new XSLTProcessor;
$proc->importStyleSheet($xsl);

// 4. Aplicar transformación
$result = $proc->transformToXML($xml);

if ($result === false) {
    echo "Error: La transformación XSLT falló.\n";
    exit(1);
}

// 5. Mostrar o guardar
if ($outputFile) {
    file_put_contents($outputFile, $result);
    echo "Transformación completada. Resultado guardado en: $outputFile\n";
} else {
    echo $result;
}

?>
<<<<<<< HEAD

=======
>>>>>>> 849fb7ac55f2d964f8c38c4ee534a8a9d3aa8e10
