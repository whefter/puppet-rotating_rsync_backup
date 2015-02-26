define rotating_rsync_backup::job
(
    $configpath         = $rotating_rsync_backup::configpath,
    $ensure             = present,
    
    $user               = 'root',
    
    $sources,
    $target,
    $target_ident       = '',
    $ssh                = false,
    $main_max,
    $daily_max,
    $weekly_max,
    $monthly_max,
    $relative           = false,
    
    $cron_minute        = '*',
    $cron_hour          = '*',
    $cron_monthday      = '*',
    $cron_month         = '*',
    $cron_weekday       = '*',
) {
    validate_absolute_path( $configpath )
    validate_re( $ensure, '^(present|absent)$', "Valid values for ensure are 'present' or 'absent'" )
    
    validate_string( $user )
    
    # validate_array( $sources )
    # validate_absolute_path( $target )
    if !is_integer($main_max) { fail('main_max must be an integer') }
    if !is_integer($daily_max) { fail('daily_max must be an integer') }
    if !is_integer($weekly_max) { fail('weekly_max must be an integer') }
    if !is_integer($monthly_max) { fail('monthly_max must be an integer') }

    validate_bool( $relative )    
    validate_bool( $ssh )    
    
    # if !is_integer($cron_minute) fail('cron_minute must be an integer')
    # if !is_integer($cron_hour) fail('cron_hour must be an integer')
    # if !is_integer($cron_monthday) fail('cron_monthday must be an integer')
    # if !is_integer($cron_month) fail('cron_month must be an integer')
    # if !is_integer($cron_weekday) fail('cron_weekday must be an integer')
    
    $finalconfigpath = "${configpath}/${name}.conf"
    
    if ( $ensure == 'present' )
    {
        file { $finalconfigpath:
            ensure      => file,
            owner       => 'root',
            group       => 'root',
            mode        => 0644,
            content     => template( 'rotating_rsync_backup/config.conf.erb' )
        }
        ->
        cron { "rotating_rsync_backup_${name}":
            ensure      => present,
            command     => "${rotating_rsync_backup::installpath}/rotating-rsync-backup.pl \"${finalconfigpath}\"",
            hour        => $cron_hour,
            minute      => $cron_minute,
            month       => $cron_month,
            monthday    => $cron_monthday,
            weekday     => $cron_weekday,
            user        => $user,
        }
    }
    elsif ( $ensure == 'absent' )
    {
        cron { "rotating_rsync_backup_${name}":
            ensure      => absent,
        }
        ->
        file { $finalconfigpath:
            ensure      => absent,
        }
    }
}
