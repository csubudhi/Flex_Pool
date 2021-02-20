#PS Script to pull Flexpool.io API data

   
   #Change The Miner names here, EG $MinerWorker1 = "SomeGreatMinerName" add more workers if needed

   function make_dir {
   if(!(Test-Path C:\temp\flexpool_data))
   {
    New-Item 'C:\temp\flexpool_data' -ItemType Directory
    }
    else {}
    }
 #call function to make new dir for flexpool data
 make_dir

#Change The Miner names here, EG $MinerWorker1 = "SomeGreatMinerName" add more workers if needed
#If you have a bunch of miners you prob want to import a CSV in a foreach loop eg. foreach($miner in $miners) { } 

   $MinerWorker1 = "MinerWorker1"
   $MinerWorker2 = "MinerWorker2"
   $MinerWorker3 = "MinerWorker3"

   #Get User input
    $addy = read-host "Enter Your ETH Address"
    Write-Host "How often would you like to pull data in seconds?" -ForegroundColor Black -BackgroundColor Green
    $sleep_time = Read-Host "Time in Seconds"
   
    
   #Define URI
    $pool_addy = '0x7F101fE45e6649A6fB8F3F8B43ed03D353f2B90c'

    #1 ether = 1,000,000,000,000,000,000 wei
    #Define more vars
    $wei = 1000000000000000000
    $date = (get-date).DateTime
    $date_day = (get-date).DayOfWeek
    $R = Get-Random

    #infinite loop for calling connect function  
    while(1)
    {
       #date and time
       $date = (get-date).DateTime

       #Return daily effective, and current reported hashrate
       $minerdatadaily = (Invoke-RestMethod -Method 'get' -Uri $UrlDaily) 
       #current pool luck
       $luck = (Invoke-RestMethod -Method 'get' -Uri $UrlLuck)
   
       #Returns current effective, and current reported hashrate
       #This is ther area you would change to add OR remove workers!!!!
       $miner_current = (Invoke-RestMethod -method 'get' -Uri https://flexpool.io/api/v1/miner/$addy/current)
       $miner_current_worker1 = (Invoke-RestMethod -method 'get' -Uri https://flexpool.io/api/v1/worker/$addy/$MinerWorker1/current)
       $miner_current_worker2 = (Invoke-RestMethod -method 'get' -Uri https://flexpool.io/api/v1/worker/$addy/$MinerWorker2/current)
       $miner_current_worker3 = (Invoke-RestMethod -method 'get' -Uri https://flexpool.io/api/v1/worker/$addy/$MinerWorker3/current)

	    #Returns ETH Ballance
       $ETH_Bal = (Invoke-RestMethod -method 'get' -Uri https://flexpool.io/api/v1/miner/$addy/balance)
   
       $data3 = @{
       ETH = $ETH_Bal.result/$wei
       Date = $date
  
       }

       $data2 = [ordered] @{
       Mh_effective_hashrate_current= [math]::Round(($miner_current.result.effective_hashrate)/1000000,2)


       Worker1_MH = [math]::Round(($miner_current_worker1.result.reported_hashrate)/1000000,2)
       Worker2_MH = [math]::Round(($miner_current_worker2.result.reported_hashrate)/1000000,2)
       Worker3_MH = [math]::Round(($miner_current_worker3.result.reported_hashrate)/1000000,2)

       Mh_reported_hashrate_current = [math]::Round(($miner_current.result.reported_hashrate)/1000000,2)

       Mh_Eff_vs_Reported = ([math]::Round(($miner_current.result.effective_hashrate)/1000000,2)) -([math]::Round(($miner_current.result.reported_hashrate)/1000000,2))
   
       Mh_invaild_shares_current = [math]::Round(($miner_current.result.invalid_shares)/1000000,2)
   
       Pool_Luck = $luck.result
       Date = $Date
       }

       $data1 = [ordered] @{
       Mh_effective_hashrate_daily = [math]::Round(($minerdatadaily.result.effective_hashrate)/1000000,2)
       Mh_reported_hashrate_daily = [math]::Round(($minerdatadaily.result.reported_hashrate)/1000000,2)
       Mh_invaild_shares_daily = [math]::Round(($minerdatadaily.result.invalid_shares)/1000000,2)
       stale_shares_daily = $minerdatadaily.result.stale_shares
       Valid_shares_daily = $minerdatadaily.result.valid_shares
       Pool_Luck = $luck.result
       Date = $Date
       }

       Write-Host "DAILY DATA" -ForegroundColor Black -BackgroundColor Green
       [PSCustomObject] $data1
       [PSCustomObject] $data1 | Export-Csv C:\temp\flexpool_data\daily-$date_day-$R.csv -NoTypeInformation -force -Append
  
       Write-Host "CURRENT DATA" -ForegroundColor Black -BackgroundColor RED
       [PSCustomObject] $data2
       [PSCustomObject] $data2 | Export-Csv C:\temp\flexpool_data\urrent-$date_day-$R.csv -NoTypeInformation -force -Append
       [PSCustomObject] $data3
       [PSCustomObject] $data3 | Export-Csv C:\temp\flexpool_data\ballance-$date_day-$R.csv -NoTypeInformation -force -Append
       start-sleep -seconds $sleep_time

    }
