<?php
$pdo = new PDO("mysql:host=webser-db.cnfwqqp77kpf.eu-west-2.rds.amazonaws.com;dbname=webserver", 'webserver', 'webserver');
$pdo->setAttribute(PDO::MYSQL_ATTR_USE_BUFFERED_QUERY, false);

$cityName = $pdo->query("SELECT Name FROM city");
foreach ($cityName as $row) {
        echo $row['Name'] . PHP_EOL;
}

$location = $pdo->query("SELECT Location FROM city");
foreach ($location as $row) {
        echo $row['Location'] . PHP_EOL;
}

$population = $pdo->query("SELECT Population FROM city");
foreach ($population as $row) {
        echo $row['Population'] . PHP_EOL;
}

?>
