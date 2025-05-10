<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "duobul";
$port = 3307;

$conn = new mysqli($servername, $username, $password, $dbname, $port);

if ($conn->connect_error) {
    die(json_encode(['error' => 'Connection failed: ' . $conn->connect_error]));
}

$user_id = $_GET['user_id'];

$sql = "SELECT username, email, profile_image, favorite_games FROM users WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    $row['favorite_games'] = json_decode($row['favorite_games'] ?? '[]');
    echo json_encode($row);
} else {
    echo json_encode(['error' => 'User not found']);
}

$stmt->close();
$conn->close();
?> 