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

##### AWS  #####

Set-AWSCredential -AccessKey AccessKeyEXAMPLE -SecretKey secretkeyExample -StoreAs MyAWSProfile  # setting AWS credentials

#2 methods for allow/deny CIDR block, on AWS Security Group and AWS Network ACL

$TableAllow=GetAllowDataFromDB # add function result in a variable
foreach ($Entry in $TableAllow)  # for each row from the output table of SQL query we are adding new rules on AWS security group 
    {
      aws ec2 authorize-security-group-ingress -group-id sg-1234567890abcdef0 -protocol tcp -port $Entry.port -cidr $Entry.IPblock
    }
    
$TableDeny=GetDenyDataFromDB # add function result in a variable
foreach ($Entry in $TableDeny)  # for each row from the output table of SQL query we are adding new rules on AWS Network ACL 
    {
      aws ec2 create-network-acl-entry -network-acl-id acl-123456 -ingress -rule-number 99 -protocol tcp -port-range From= $Entry.port,To= $Entry.port -cidr-block $Entry.IPblock -rule-action deny
    }  
    

