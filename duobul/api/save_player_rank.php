<?php
// Tüm hata mesajlarını aç
ini_set('display_errors', 1); // Hata mesajlarını göster
error_reporting(E_ALL);
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

// Tüm çıktıları tamponla ve temizle
ob_start();

try {
    // JSON verisini al
    $input = json_decode(file_get_contents('php://input'), true);
    if (!$input) throw new Exception("Geçersiz JSON verisi");

    // Veritabanı bağlantısı
    $pdo = new PDO(
        'mysql:host=192.168.51.187;port=3307;dbname=usersinfo',
        'root',
        '',
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_EMULATE_PREPARES => false
        ]
    );

    // Sorguyu çalıştır
    $stmt = $pdo->prepare("INSERT INTO user_ranks (email, rank) VALUES (:email, :rank) ON DUPLICATE KEY UPDATE rank = :rank_update, created_at = CURRENT_TIMESTAMP");
    $stmt->execute([
        ':email' => $input['email'],
        ':rank' => (int)$input['rank'],
        ':rank_update' => (int)$input['rank']
    ]);

    // Tüm çıktıları temizle
    ob_end_clean();
    
    // Başarılı yanıt
    die(json_encode(['success' => true]));

} catch (Exception $e) {
    // Hata durumunda
    ob_end_clean();
    http_response_code(500);
    die(json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]));
}
?>