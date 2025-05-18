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

if (!isset($data['email']) || !isset($data['min_rank']) || !isset($data['max_rank'])) {
    echo json_encode(['success' => false, 'message' => 'Eksik parametreler']);
    exit;
}

$email = $data['email'];
$minRank = intval($data['min_rank']);
$maxRank = intval($data['max_rank']);

try {
    // Kullanıcının oyun tipini al
    $stmt = $conn->prepare("SELECT game_type FROM user_ranks WHERE email = ?");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        echo json_encode(['success' => false, 'message' => 'Kullanıcı rank bilgisi bulunamadı']);
        exit;
    }
    
    $row = $result->fetch_assoc();
    $gameType = $row['game_type'];
    
    // Rank aralığındaki kullanıcıları bul
    $stmt = $conn->prepare("
        SELECT ur.email, ur.rank, u.username
        FROM user_ranks ur
        JOIN users u ON ur.email = u.email
        WHERE ur.game_type = ? 
        AND ur.email != ?
        AND ur.rank BETWEEN ? AND ?
        ORDER BY ur.rank ASC
    ");
    $stmt->bind_param("ssii", $gameType, $email, $minRank, $maxRank);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $users = [];
    while ($row = $result->fetch_assoc()) {
        $users[] = [
            'email' => $row['email'],
            'username' => $row['username'],
            'rank' => $row['rank']
        ];
    }
    
    echo json_encode([
        'success' => true,
        'users' => $users
    ]);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Hata: ' . $e->getMessage()]);
}

$stmt->close();
$conn->close();
?> 