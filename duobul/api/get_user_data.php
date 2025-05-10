<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

try {
    $pdo = new PDO("mysql:host=localhost;port=3307;dbname=usersinfo", "root", "");
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $email = $_GET['email'] ?? '';

    if (empty($email)) {
        echo json_encode(['success' => false, 'error' => 'Email parametresi gerekli']);
        exit;
    }

    $stmt = $pdo->prepare("SELECT * FROM users WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user) {
        // Profil fotoğrafını base64 formatına çevir
        if ($user['profile_photo']) {
            $user['profile_photo'] = base64_encode($user['profile_photo']);
        }
        
        // Favori oyunları JSON formatına çevir
        if ($user['favorite_games']) {
            $user['favorite_games'] = json_decode($user['favorite_games']);
        }

        echo json_encode(['success' => true, 'data' => $user]);
    } else {
        echo json_encode(['success' => false, 'error' => 'Kullanıcı bulunamadı']);
    }
} catch(PDOException $e) {
    echo json_encode(['success' => false, 'error' => 'Veritabanı hatası: ' . $e->getMessage()]);
}
?> 