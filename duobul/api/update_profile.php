<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

try {
    // Veritabanı bağlantısı
    $pdo = new PDO("mysql:host=localhost;port=3307;dbname=usersinfo", "root", "");
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // POST verilerini al
    $email = $_POST['email'] ?? '';
    $favorite_games = $_POST['favorite_games'] ?? '';
    $username = $_POST['username'] ?? '';

    if (empty($email) || empty($favorite_games) || empty($username)) {
        echo json_encode([
            'success' => false,
            'error' => 'Eksik veri gönderildi'
        ]);
        exit;
    }

    // Profil fotoğrafını kontrol et
    $profile_photo = null;
    if (isset($_FILES['profile_photo']) && $_FILES['profile_photo']['error'] === UPLOAD_ERR_OK) {
        $profile_photo = file_get_contents($_FILES['profile_photo']['tmp_name']);
    }

    // Verileri güncelle
    $sql = "UPDATE users SET favorite_games = :favorite_games, username = :username";
    $params = [
        ':favorite_games' => $favorite_games,
        ':username' => $username
    ];

    if ($profile_photo !== null) {
        $sql .= ", profile_photo = :profile_photo";
        $params[':profile_photo'] = $profile_photo;
    }

    $sql .= " WHERE email = :email";
    $params[':email'] = $email;

    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);

    if ($stmt->rowCount() > 0) {
        echo json_encode([
            'success' => true,
            'message' => 'Profil başarıyla güncellendi'
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'error' => 'Kullanıcı bulunamadı'
        ]);
    }

} catch(PDOException $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Veritabanı hatası: ' . $e->getMessage()
    ]);
} catch(Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Sunucu hatası: ' . $e->getMessage()
    ]);
}
?> 