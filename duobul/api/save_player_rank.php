<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "usersinfo";
$port = 3307;

$conn = new mysqli($servername, $username, $password, $dbname, $port);

if ($conn->connect_error) {
    die(json_encode(['success' => false, 'message' => 'Veritabanı bağlantı hatası: ' . $conn->connect_error]));
}

$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['email']) || !isset($data['rank']) || !isset($data['game_type'])) {
    echo json_encode(['success' => false, 'message' => 'Eksik parametreler']);
    exit;
}

$email = $data['email'];
$rank = intval($data['rank']);
$gameType = $data['game_type'];

try {
    // Önce kullanıcının rank kaydı var mı kontrol et
    $stmt = $conn->prepare("SELECT id FROM user_ranks WHERE email = ? AND game_type = ?");
    $stmt->bind_param("ss", $email, $gameType);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        // Varsa güncelle
        $stmt = $conn->prepare("UPDATE user_ranks SET rank = ? WHERE email = ? AND game_type = ?");
        $stmt->bind_param("iss", $rank, $email, $gameType);
    } else {
        // Yoksa yeni kayıt ekle
        $stmt = $conn->prepare("INSERT INTO user_ranks (email, game_type, rank) VALUES (?, ?, ?)");
        $stmt->bind_param("ssi", $email, $gameType, $rank);
    }

    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'Rank başarıyla kaydedildi']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Rank kaydedilemedi']);
    }
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Hata: ' . $e->getMessage()]);
}

$stmt->close();
$conn->close();
?> 