<?php
file_put_contents('debug_log.txt', "PHP çalıştı\n", FILE_APPEND);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Accept');

// MySQL bağlantı bilgileri
$host = 'localhost';
$dbname = 'usersinfo';
$username = 'root';
$password = '';

ini_set('display_errors', 1);
error_reporting(E_ALL);


try {
    $pdo = new PDO("mysql:host=$host;port=3307;dbname=$dbname", $username, $password);

    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Veritabanı bağlantı hatası: ' . $e->getMessage()]);
    exit;
}

// Gelen verileri al
$input = file_get_contents('php://input');
$data = json_decode($input, true);

if ($data) {
    $username = $data['username'];
    $email = $data['email'];
    $password = password_hash($data['password'], PASSWORD_DEFAULT);

    try {
        // Önce e-posta adresinin kullanılıp kullanılmadığını kontrol et
        $checkStmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
        $checkStmt->execute([$email]);
        
        if ($checkStmt->rowCount() > 0) {
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'error' => 'Bu e-posta adresi zaten kullanılıyor'
            ]);
            exit;
        }

        // Yeni kullanıcıyı ekle
        $stmt = $pdo->prepare("INSERT INTO users (username, email, password) VALUES (?, ?, ?)");
        $stmt->execute([$username, $email, $password]);
        
        http_response_code(201);
        echo json_encode([
            'success' => true,
            'message' => 'Kayıt başarılı'
        ]);
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'error' => 'Kayıt başarısız: ' . $e->getMessage()
        ]);
    }
} else {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => 'Geçersiz veri'
    ]);
}
?>