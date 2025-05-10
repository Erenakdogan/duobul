<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

try {
    // Veritabanı bağlantısı
    $pdo = new PDO("mysql:host=192.168.51.187;port=3307;dbname=usersinfo", "root", "");
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // POST verilerini al
    $data = json_decode(file_get_contents('php://input'), true);
    $email = $data['email'] ?? '';

    if (empty($email)) {
        echo json_encode([
            'success' => false,
            'error' => 'E-posta adresi gerekli'
        ]);
        exit;
    }

    // Debug için gelen veriyi logla
    error_log("Gelen e-posta: " . $email);

    // Kullanıcı bilgilerini getir
    $stmt = $pdo->prepare("SELECT username, favorite_games, profile_photo FROM users WHERE email = :email");
    $stmt->execute([':email' => $email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    // Debug için veritabanı sonucunu logla
    error_log("Veritabanı sonucu: " . print_r($user, true));

    if ($user) {
        $response = [
            'success' => true,
            'username' => $user['username'],
            'favorite_games' => $user['favorite_games'] ?? '',
            'profile_photo' => $user['profile_photo'] ? base64_encode($user['profile_photo']) : null
        ];
        
        // Debug için yanıtı logla
        error_log("Gönderilen yanıt: " . json_encode($response));
        
        echo json_encode($response);
    } else {
        echo json_encode([
            'success' => false,
            'error' => 'Kullanıcı bulunamadı'
        ]);
    }

} catch(PDOException $e) {
    error_log("Veritabanı hatası: " . $e->getMessage());
    echo json_encode([
        'success' => false,
        'error' => 'Veritabanı hatası: ' . $e->getMessage()
    ]);
} catch(Exception $e) {
    error_log("Sunucu hatası: " . $e->getMessage());
    echo json_encode([
        'success' => false,
        'error' => 'Sunucu hatası: ' . $e->getMessage()
    ]);
}
?> 