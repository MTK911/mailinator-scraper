$GOAL=@()
$COLET=@()
$mailbox = @("test","testing","qa","test123","123","abc","asd","qwerty","demo","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","1","2","3","4","5","6","7","8","9","0")
$subject_words = @("password","register","signup","signin","welcome","PIN","forget","reset","OTP","verify","Confirmation","login")
#$sendername_words = @("localhost","test","testing","netflix","gmail","spotify","paypal","microsoft","amazon") #maybe not

foreach ($mailbox_exp in $mailbox) {
$COLET += echo "{""zone"":""public"",""cmd"":""sub"",""channel"":""$mailbox_exp""}"|./websocat.exe wss://www.mailinator.com/ws/fetchinbox | ConvertFrom-Json
}#Mail collector

foreach ($subject_words_exp in $subject_words) {
$GOAL += echo $COLET | select fromfull, subject, id |where-object {$_.subject -Match "$subject_words_exp"} | select id
#echo $COLET | select fromfull, subject, id |where-object {$_.subject -Match "$subject_words_exp" -or $_.fromfull -Match "hotmail"} #in case
}#Mail filter
foreach ($droper in $GOAL) {
$droper = $droper -replace "@{id=",""
$droper = $droper -replace "}",""
Invoke-WebRequest -uri "https://www.mailinator.com/fetch_email?msgid=$droper&zone=public" | Select-Object -ExpandProperty content | ConvertFrom-Json | ForEach-Object {$_.data} | ForEach-Object { $_.headers, $_.parts } | ForEach-Object { $_.date, $_.subject, $_.from, $_.to, $_.parts, $_.body} | out-file $droper+.html
}#Mail Downloader