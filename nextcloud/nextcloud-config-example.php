//Add these lines to the end of the file (before the close `);` )
// file: server_files/config/config.php

<?php

'maintenance' => false,
   'memcache.local' => '\\OC\\Memcache\\Redis',
   'redis' =>
   array (
     'host' => 'redis',
     'port' => 6379,
   ),
   'memcache.locking' => '\\OC\\Memcache\\Redis',

'overwritehost' => 'nextcloud.reclusivy.com',
#'default_phone_region' => 'US',
