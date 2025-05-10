<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

try {
    $pdo = new PDO("mysql:host=localhost;port=3307;dbname=usersinfo", "root", "");
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $email = $_POST['email'] ?? '';
    $favorite_games = $_POST['favorite_games'] ?? '[]';

    if (empty($email)) {
        echo json_encode(['success' => false, 'error' => 'Email parametresi gerekli']);
        exit;
    }

    // Profil fotoğrafı kontrolü
    $profile_photo = null;
    if (isset($_FILES['profile_photo']) && $_FILES['profile_photo']['error'] === UPLOAD_ERR_OK) {
        $profile_photo = file_get_contents($_FILES['profile_photo']['tmp_name']);
    }

    // SQL sorgusunu hazırla
    $sql = "UPDATE users SET favorite_games = ?";
    $params = [$favorite_games];

    if ($profile_photo !== null) {
        $sql .= ", profile_photo = ?";
        $params[] = $profile_photo;
    }

    $sql .= " WHERE email = ?";
    $params[] = $email;

    $stmt = $pdo->prepare($sql);
    $result = $stmt->execute($params);

    if ($result) {
        echo json_encode(['success' => true, 'message' => 'Profil başarıyla güncellendi']);
    } else {
        echo json_encode(['success' => false, 'error' => 'Profil güncellenirken bir hata oluştu']);
    }
} catch(PDOException $e) {
    echo json_encode(['success' => false, 'error' => 'Veritabanı hatası: ' . $e->getMessage()]);
}
?> 