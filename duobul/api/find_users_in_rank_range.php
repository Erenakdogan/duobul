<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once 'db_connect.php';

$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['email']) || !isset($data['min_rank']) || !isset($data['max_rank'])) {
    echo json_encode(['success' => false, 'message' => 'Eksik parametreler']);
    exit;
}

$email = $data['email'];
$minRank = $data['min_rank'];
$maxRank = $data['max_rank'];

try {
    // Kullanıcının oyun tipini al
    $stmt = $conn->prepare("SELECT game_type FROM player_ranks WHERE email = ?");
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
        SELECT pr.email, pr.rank, u.username
        FROM player_ranks pr
        JOIN users u ON pr.email = u.email
        WHERE pr.game_type = ? 
        AND pr.email != ?
        AND pr.rank BETWEEN ? AND ?
        ORDER BY pr.rank ASC
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