define rotating_rsync_backup::job
(
  $ensure        = present,
  $user          = 'root',
  $config        = '',
  $cron_minute   = '*',
  $cron_hour     = '*',
  $cron_monthday = '*',
  $cron_month    = '*',
  $cron_weekday  = '*',
  $cron_stdout   = undef,
  $cron_stderr   = undef,
) {
  $configpath_final = join([ $::rotating_rsync_backup::configpath, '/', regsubst($name, '[^a-zA-Z0-9_-]', '_', 'G'), '.conf' ])

  validate_re( $ensure, '^(present|absent)$', "Valid values for ensure are 'present' or 'absent'" )

  if $ensure == 'present' {
    validate_absolute_path( $::rotating_rsync_backup::configpath )
    validate_string( $user )

    # if !is_integer($cron_minute) fail('cron_minute must be an integer')
    # if !is_integer($cron_hour) fail('cron_hour must be an integer')
    # if !is_integer($cron_monthday) fail('cron_monthday must be an integer')
    # if !is_integer($cron_month) fail('cron_month must be an integer')
    # if !is_integer($cron_weekday) fail('cron_weekday must be an integer')

    file { $configpath_final:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      # content => template('rotating_rsync_backup/config.conf.erb'),
      content => $config,
      before  => [
        Cron["rotating_rsync_backup_${name}"],
      ],
    }
  } elsif $ensure == 'absent' {
    file { $configpath_final:
      ensure => absent,
      after  => [
        Cron["rotating_rsync_backup_${name}"],
      ],
    }
  }
  
  if $cron_stdout {
    $_cron_stdout = "1>>'${cron_stdout}'"
  } else {
    $_cron_stdout = ""
  }
  if $cron_stderr {
    $_cron_stderr = "2>>'${cron_stderr}'"
  } else {
    $_cron_stderr = ""
  }

  cron { "rotating_rsync_backup_${name}":
    ensure   => $ensure,
    command  => "${::rotating_rsync_backup::installpath}/rotating-rsync-backup.pl \"${configpath_final}\" ${_cron_stdout} ${_cron_stderr}",
    hour     => $cron_hour,
    minute   => $cron_minute,
    month    => $cron_month,
    monthday => $cron_monthday,
    weekday  => $cron_weekday,
    user     => $user,
  }
}
