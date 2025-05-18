<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Hata raporlamayı aç
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "usersinfo";
$port = 3307;

try {
    $conn = new mysqli($servername, $username, $password, $dbname, $port);

    if ($conn->connect_error) {
        throw new Exception('Veritabanı bağlantı hatası: ' . $conn->connect_error);
    }

    // Karakter setini ayarla
    if (!$conn->set_charset("utf8mb4")) {
        throw new Exception('Karakter seti ayarlanamadı: ' . $conn->error);
    }

    // Gelen veriyi logla
    $raw_input = file_get_contents('php://input');
    error_log("Gelen veri: " . $raw_input);

    $data = json_decode($raw_input, true);

    if (!$data) {
        throw new Exception('JSON çözümleme hatası: ' . json_last_error_msg());
    }

    if (!isset($data['email']) || !isset($data['rank'])) {
        throw new Exception('Eksik parametreler: email ve rank gerekli');
    }

    $email = $data['email'];
    $targetRank = intval($data['rank']);

    // Kullanıcının oyun tipini al
    $query = "SELECT game_type FROM user_ranks WHERE email = ?";
    $stmt = $conn->prepare($query);
    if (!$stmt) {
        throw new Exception('Sorgu hazırlama hatası: ' . $conn->error);
    }

    $stmt->bind_param("s", $email);
    if (!$stmt->execute()) {
        throw new Exception('Sorgu çalıştırma hatası: ' . $stmt->error);
    }

    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        throw new Exception('Kullanıcı rank bilgisi bulunamadı');
    }
    
    $row = $result->fetch_assoc();
    $gameType = $row['game_type'];
    
    // En yakın rankı bul
    $query = "
        SELECT u.email, u.username, ur.rank, ABS(ur.rank - ?) as rank_diff 
        FROM users u 
        INNER JOIN user_ranks ur ON u.email = ur.email 
        WHERE ur.game_type = ? 
        AND ur.email != ? 
        ORDER BY rank_diff ASC 
        LIMIT 1
    ";

    $stmt = $conn->prepare($query);
    if (!$stmt) {
        throw new Exception('Sorgu hazırlama hatası: ' . $conn->error);
    }

    $stmt->bind_param("iss", $targetRank, $gameType, $email);
    if (!$stmt->execute()) {
        throw new Exception('Sorgu çalıştırma hatası: ' . $stmt->error);
    }

    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        echo json_encode([
            'success' => true,
            'closest' => [
                'email' => $row['email'],
                'username' => $row['username'],
                'rank' => $row['rank'],
                'rank_diff' => $row['rank_diff']
            ]
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Yakın rank bulunamadı'
        ]);
    }

} catch (Exception $e) {
    error_log("Hata: " . $e->getMessage());
    echo json_encode([
        'success' => false,
        'message' => 'Hata: ' . $e->getMessage()
    ]);
} finally {
    if (isset($stmt)) {
        $stmt->close();
    }
    if (isset($conn)) {
        $conn->close();
    }
}
?> 