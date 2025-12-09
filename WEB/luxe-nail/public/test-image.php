<?php
// Test if served-image route works
$testImage = 'img/kategori/ai_shape/1764524358_Natural Round.jpg';
$url = 'https://web-luxe-nail-main-jfcax3.laravel.cloud/served-image/' . urlencode($testImage);

echo "<h1>Image Test</h1>";
echo "<p>Testing URL: <code>$url</code></p>";
echo "<img src='$url' style='max-width: 300px;' />";
echo "<hr>";
echo "<p>If image shows above, route works. If not, route has issue.</p>";

// Also test direct public path
$directUrl = 'https://web-luxe-nail-main-jfcax3.laravel.cloud/' . $testImage;
echo "<h2>Direct Public Path Test</h2>";
echo "<p>Testing URL: <code>$directUrl</code></p>";
echo "<img src='$directUrl' style='max-width: 300px;' />";
