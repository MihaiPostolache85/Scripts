function GetAllowDataFromDB {

#database connection and query to pull Allowed values

    [string] $dataSource = "localhost\SQLEXPRESS"
    [string] $database   = "CIDR"
    [string] $sqlCommand = "select IPblock, Port from CIDR where Allow='Yes'"  
      

    $connectionString = "Data Source=$dataSource; " +
                        "Integrated Security=SSPI; " +
                        "Initial Catalog=$database"

    $connection = new-object system.data.SqlClient.SQLConnection($connectionString)
    $command = new-object system.data.sqlclient.sqlcommand($sqlCommand,$connection)
    $connection.Open()

    $adapter = New-Object System.Data.sqlclient.sqlDataAdapter $command
    $dataset = New-Object System.Data.DataSet
    $adapter.Fill($dataSet) | Out-Null

    $connection.Close()
    $dataSet.Tables

}

function GetDenyDataFromDB {

#database connection and query to pull Denied values

    [string] $dataSource = "localhost\SQLEXPRESS"
    [string] $database   = "CIDR"
    [string] $sqlCommand = "select IPblock, Port from CIDR where Allow='No'"  
      

    $connectionString = "Data Source=$dataSource; " +
                        "Integrated Security=SSPI; " +
                        "Initial Catalog=$database"

    $connection = new-object system.data.SqlClient.SQLConnection($connectionString)
    $command = new-object system.data.sqlclient.sqlcommand($sqlCommand,$connection)
    $connection.Open()

    $adapter = New-Object System.Data.sqlclient.sqlDataAdapter $command
    $dataset = New-Object System.Data.DataSet
    $adapter.Fill($dataSet) | Out-Null

    $connection.Close()
    $dataSet.Tables

}
##### Azure #####

az login -u <username> -p <password>  # simple login method, however if we don't want to display in plain text the password there are other alternatives

$TableAllow=GetAllowDataFromDB 
foreach ($Entry in $TableAllow)  # for each row from the output table of SQL query we are adding new rules on Azure Network security group 
    {
    az network nsg rule create -g MyResourceGroup --nsg-name MyNsg -n MyNsgRule --priority 4096 --source-address-prefixes $Entry.IPblock --source-port-ranges $Entry.port --destination-address-prefixes '*' --destination-port-ranges $Entry.port --access Allow --protocol Tcp --description "Allow requests from specific IP address ranges on port"+ $Entry.port + "."
     } 


$TableDeny=GetDenyDataFromDB # add function result in a variable
foreach ($Entry in $TableAllow)  # for each row from the output table of SQL query we are adding new rules on Azure Network security group , setting low priority because lower numbers have higher priority and the "Deny" rules should be taken first
    {
    az network nsg rule create -g MyResourceGroup --nsg-name MyNsg -n MyNsgRule --priority 100 --source-address-prefixes $Entry.IPblock --source-port-ranges $Entry.port --destination-address-prefixes '*' --destination-port-ranges $Entry.port --access Deny --protocol Tcp --description "Deny requests from specific IP address ranges on port"+ $Entry.port + "."
     } 
