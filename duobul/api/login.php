<?php
// Hata raporlamayı aç
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Accept');

// MySQL bağlantı bilgileri
$host = 'localhost';
$dbname = 'usersinfo';
$username = 'root';
$password = '';

try {
    // Veritabanı bağlantısı
    $pdo = new PDO("mysql:host=$host;port=3307;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Debug için bağlantı başarılı mesajı
    error_log("Veritabanı bağlantısı başarılı");
} catch(PDOException $e) {
    error_log("Veritabanı bağlantı hatası: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false, 
        'error' => 'Veritabanı bağlantı hatası: ' . $e->getMessage()
    ]);
    exit;
}

// Gelen verileri al
$input = file_get_contents('php://input');
error_log("Gelen veri: " . $input);

$data = json_decode($input, true);

if (!$data) {
    error_log("Geçersiz JSON verisi");
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => 'Geçersiz veri formatı'
    ]);
    exit;
}

// Gerekli alanları kontrol et
if (!isset($data['email']) || !isset($data['password'])) {
    error_log("Eksik alanlar: " . print_r($data, true));
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => 'E-posta ve şifre gerekli'
    ]);
    exit;
}

$email = $data['email'];
$password = $data['password'];

try {
    // Kullanıcıyı sorgula
    $stmt = $pdo->prepare("SELECT * FROM users WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        error_log("Kullanıcı bulunamadı: $email");
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'error' => 'Geçersiz e-posta veya şifre'
        ]);
        exit;
    }

    // Şifre kontrolü
    if (!password_verify($password, $user['password'])) {
        error_log("Geçersiz şifre denemesi: $email");
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'error' => 'Geçersiz e-posta veya şifre'
        ]);
        exit;
    }

    // Başarılı giriş
    error_log("Başarılı giriş: $email");
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'user' => [
            'id' => $user['id'],
            'username' => $user['username'],
            'email' => $user['email'],
            'favorite_games' => $user['favorite_games'] ?? '',
            'profile_photo' => $user['profile_photo'] ? base64_encode($user['profile_photo']) : null
        ]
    ]);

} catch(PDOException $e) {
    error_log("Sorgu hatası: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Veritabanı hatası: ' . $e->getMessage()
    ]);
} catch(Exception $e) {
    error_log("Genel hata: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Sunucu hatası: ' . $e->getMessage()
    ]);
}
?>