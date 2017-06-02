<html>
<head>
    <title>PHP Test</title>
</head>
    <body>
    <?php echo '<p>Thanks for trying the CAM Lamp stack starter pack</p>';
    // In the variables section below, replace user and password with your own MySQL credentials as created on your server
    $servername = "localhost";
    $username = "dbuser";
    $password = "dbpassword";

    // Create MySQL connection
    $conn = mysqli_connect($servername, $username, $password);

    // Check connection - if it fails, output will include the error message
    if (!$conn) {
        die('<p>Connection failed: <p>' . mysqli_connect_error());
    }
    echo '<p>Connected successfully to MySQL DB</p>';
    echo '<p>If you would like more information on IBM\'s cloud management products, checkout this <a href="https://www.ibm.com/cloud-computing/products/cloud-management/">link</a></p>';
    ?>
</body>
</html>
