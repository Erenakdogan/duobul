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

if (!isset($data['email']) || !isset($data['game_type'])) {
    echo json_encode(['success' => false, 'message' => 'Eksik parametreler']);
    exit;
}

$email = $data['email'];
$gameType = $data['game_type'];

try {
    $stmt = $conn->prepare("SELECT rank FROM user_ranks WHERE email = ? AND game_type = ?");
    $stmt->bind_param("ss", $email, $gameType);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        echo json_encode(['success' => true, 'rank' => $row['rank']]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Rank bulunamadı']);
    }
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Hata: ' . $e->getMessage()]);
}

$stmt->close();
$conn->close();
?> 