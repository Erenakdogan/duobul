<?php
// Hata raporlamayı aç
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// CORS ayarları
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Accept');

// OPTIONS isteği için erken yanıt
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Gelen veriyi logla
error_log("Gelen istek metodu: " . $_SERVER['REQUEST_METHOD']);
error_log("Gelen veri: " . file_get_contents('php://input'));

// Test yanıtı
$response = [
    'success' => true,
    'message' => 'API çalışıyor',
    'debug' => [
        'request_method' => $_SERVER['REQUEST_METHOD'],
        'content_type' => $_SERVER['CONTENT_TYPE'] ?? 'not set',
        'raw_input' => file_get_contents('php://input')
    ]
];

// JSON yanıtı gönder
echo json_encode($response, JSON_PRETTY_PRINT);
?>