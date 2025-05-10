<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Accept');

// OPTIONS isteği için erken yanıt
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Veritabanı bağlantısı
try {
    $pdo = new PDO("mysql:host=192.168.51.187;port=3307;dbname=usersinfo", "root", "");
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Veritabanı bağlantı hatası',
        'common_games' => []
    ]);
    exit;
}

// POST verilerini al
$data = json_decode(file_get_contents('php://input'), true);

// Gerekli alanları kontrol et
if (!isset($data['email1']) || !isset($data['email2'])) {
    echo json_encode([
        'success' => false,
        'error' => 'Eksik veri',
        'common_games' => []
    ]);
    exit;
}

try {
    // İlk kullanıcının favori oyunlarını al
    $stmt = $pdo->prepare("SELECT favorite_games FROM users WHERE email = ?");
    $stmt->execute([$data['email1']]);
    $user1 = $stmt->fetch(PDO::FETCH_ASSOC);

    // İkinci kullanıcının favori oyunlarını al
    $stmt->execute([$data['email2']]);
    $user2 = $stmt->fetch(PDO::FETCH_ASSOC);

    // Kullanıcılar bulunamadıysa
    if (!$user1 || !$user2) {
        echo json_encode([
            'success' => false,
            'error' => 'Kullanıcılar bulunamadı',
            'common_games' => []
        ]);
        exit;
    }

    // Favori oyunları diziye çevir
    $games1 = $user1['favorite_games'] ? explode(',', $user1['favorite_games']) : [];
    $games2 = $user2['favorite_games'] ? explode(',', $user2['favorite_games']) : [];

    // Ortak oyunları bul
    $common_games = array_intersect($games1, $games2);
    $common_games = array_values($common_games); // Diziyi yeniden indeksle

    echo json_encode([
        'success' => true,
        'common_games' => $common_games
    ]);

} catch(PDOException $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Veritabanı hatası',
        'common_games' => []
    ]);
}
?> 